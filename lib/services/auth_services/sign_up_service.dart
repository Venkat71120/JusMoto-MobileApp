import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      debugPrint('🔁 Token re-set before profile update');
    }

    debugPrint('🔑 Auth header token present: ${getToken.isNotEmpty}');
    debugPrint(
      '📤 Sending profile update: '
      '${sum.fNameController.text.trim()} ${sum.lNameController.text.trim()}',
    );

    final Map<String, String> fields = {
      'update_type': 'after_login',
      'first_name': sum.fNameController.text.trim(),
      'last_name': sum.lNameController.text.trim(),
    };

    try {
      // Always use MultipartRequest — endpoint is multipart/form-data.
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppUrls.profileInfoUpdateUrl),
      );

      request.fields.addAll(fields);
      request.headers.addAll(acceptJsonAuthHeader);

      debugPrint('🔑 Request headers: ${request.headers}');
      debugPrint('📦 Request fields: ${request.fields}');

      // Attach profile image only when the user selected one
      if (sum.profileImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            sum.profileImage.value!.path,
          ),
        );
        debugPrint('🖼️ Profile image attached');
      }

      final responseData = await NetworkApiServices().postWithFileApi(
        request,
        LocalKeys.profileSetup,
      );

      debugPrint('📥 Profile update response: $responseData');

      if (responseData != null && responseData.isNotEmpty) {
        final message = responseData['message']?.toString() ?? '';

        if (message.toLowerCase().contains('success') ||
            responseData.containsKey('user') ||
            responseData.containsKey('data')) {
          LocalKeys.profileSetupComplete.showToast();
          return true;
        } else if (message.isNotEmpty) {
          message.showToast();
        }
      } else {
        // Empty {} response means the server returned HTML (not JSON).
        // This happens when the Authorization header is missing/wrong,
        // causing the request to hit the web frontend instead of the API.
        debugPrint(
          '❌ Empty response — auth header missing or URL not found on server',
        );
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
