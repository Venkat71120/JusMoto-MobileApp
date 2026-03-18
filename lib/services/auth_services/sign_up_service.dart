import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../view_models/sign_up_view_model/sign_up_view_model.dart';

class SignUpService with ChangeNotifier {
  bool emailVerified = true;
  bool verifyEnabled = true;
  var emailToken = "";
  var token = "";
  var email = "";
  var userId = "";

  Future tryEmailSignUp({
    required String emailUsername,
    required String password,
  }) async {
    final Map<String, dynamic> data = {
      'email': emailUsername,
      'password': password,
      'terms_conditions': true,
      'user_type': '1', // ✅ Role assignment: 1 = Client
    };

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final responseData = await NetworkApiServices().postApi(
      jsonEncode(data),
      AppUrls.emailSignUpUrl,
      LocalKeys.signUp,
      headers: headers,
    );

    debugPrint('📥 Register response: $responseData');

    if (responseData != null && responseData['data'] != null) {
      final dataObj = responseData['data'];
      final user = dataObj['user'];

      token = dataObj['token']?.toString() ?? "";
      email = user['email']?.toString() ?? "";
      userId = user['id']?.toString() ?? "";

      emailVerified = _parseToBool(user['email_verified']);
      verifyEnabled = _parseToBool(responseData['verify_enabled']);

      // ✅ CRITICAL FIX: Set global token immediately after registration
      // so acceptJsonAuthHeader is populated when profile setup is called.
      if (token.isNotEmpty) {
        setToken(token);
        debugPrint('✅ Token set globally after registration');
      } else {
        debugPrint('❌ Token missing from registration response!');
      }

      debugPrint('   emailVerified: $emailVerified');
      debugPrint('   verifyEnabled: $verifyEnabled');

      LocalKeys.youHaveSignedUpSuccessfully.showToast();
      return emailVerified || !verifyEnabled;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    return null;
  }

  Future tryToSetProfileInfos() async {
    final sum = SignUpViewModel.instance;

    // Safety net — re-set token if global token was cleared somehow
    if (token.isNotEmpty && getToken.isEmpty) {
      setToken(token);
    }

    try {
      // 1. Upload Avatar if present
      if (sum.profileImage.value != null) {
        debugPrint('🖼️ Uploading avatar...');
        final avatarRequest = http.MultipartRequest(
          'POST',
          Uri.parse(AppUrls.uploadAvatarUrl),
        );
        avatarRequest.headers.addAll(acceptJsonAuthHeader);
        
        final ext = p.extension(sum.profileImage.value!.path).toLowerCase().replaceAll('.', '');
        final mimeType = ext == 'jpg' || ext == 'jpeg' ? 'jpeg' : ext;
        
        avatarRequest.files.add(
          await http.MultipartFile.fromPath(
            'image', // ✅ Backend expects 'image'
            sum.profileImage.value!.path,
            contentType: MediaType('image', mimeType),
          ),
        );

        final avatarResponse = await NetworkApiServices().postWithFileApi(
          avatarRequest,
          LocalKeys.profileSetup,
        );

        debugPrint('📥 Avatar upload response: $avatarResponse');
        if (avatarResponse == null || (avatarResponse.containsKey('success') && avatarResponse['success'] != true) || avatarResponse.containsKey('error')) {
          final error = avatarResponse?['error'] ?? avatarResponse?['message'] ?? 'Avatar upload failed';
          error.toString().showToast();
          return null;
        }
      }

      // 2. Update Profile Info (Name)
      debugPrint('📤 Updating profile names...');
      final Map<String, String> fields = {
        'first_name': sum.fNameController.text.trim(), // ✅ snake_case
        'last_name': sum.lNameController.text.trim(),  // ✅ snake_case
      };

      final profileRequest = http.MultipartRequest(
        'POST',
        Uri.parse(AppUrls.profileInfoUpdateUrl),
      );
      profileRequest.fields.addAll(fields);
      profileRequest.headers.addAll(acceptJsonAuthHeader);

      final profileResponse = await NetworkApiServices().postWithFileApi(
        profileRequest,
        LocalKeys.profileSetup,
      );

      debugPrint('📥 Profile update response: $profileResponse');

      if (profileResponse != null && profileResponse.isNotEmpty) {
        final message = profileResponse['message']?.toString() ?? '';
        if (message.toLowerCase().contains('success') ||
            profileResponse.containsKey('user') ||
            profileResponse.containsKey('data')) {
          LocalKeys.profileSetupComplete.showToast();
          return true;
        } else if (message.isNotEmpty) {
          message.showToast();
        }
      }
    } catch (e) {
      debugPrint('❌ Profile Update Error: $e');
    }

    return null;
  }

  void sToken(String newToken) {
    token = newToken;
    notifyListeners();
  }

  bool _parseToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final s = value.toString().toLowerCase().trim();
    return s == '1' || s == 'true';
  }
}
