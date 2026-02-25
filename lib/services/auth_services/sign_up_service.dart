import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../view_models/sign_up_view_model/sign_up_view_model.dart';

/// Registers new users and sets up their profile after sign-up.
/// Backend wraps all responses in: { success, message, data: { user, token } }
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
    final data = {
      'email': emailUsername,
      'password': password,
      'terms_condition': true,
    };

    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.emailSignUpUrl,
      LocalKeys.signUp,
    );

    debugPrint('📥 Register response: $responseData');

    // Backend response shape: { success, message, data: { user: {...}, token: "..." } }
    if (responseData != null && responseData['data'] != null) {
      final dataObj = responseData['data'];
      final user = dataObj['user'];

      token = dataObj['token']?.toString() ?? "";
      email = user['email']?.toString() ?? "";
      userId = user['id']?.toString() ?? "";

      // ✅ FIX: email_verified can come back as bool, int, or string.
      //    Calling .toString() on a bool works fine, but parseToBool
      //    extension was blowing up when the raw value was already bool
      //    and something upstream tried to cast it to String first.
      //    Use _parseToBool() which handles all three types safely.
      emailVerified = _parseToBool(user['email_verified']);
      verifyEnabled = _parseToBool(responseData['verify_enabled']);

      debugPrint('   token: ${token.isNotEmpty ? "present" : "MISSING"}');
      debugPrint('   emailVerified: $emailVerified');
      debugPrint('   verifyEnabled: $verifyEnabled');

      LocalKeys.youHaveSignedUpSuccessfully.showToast();
      return emailVerified || !verifyEnabled;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    return null;
  }

  /// Called after sign-up to save first name, last name, and optional profile photo.
  /// Uses the token obtained during registration.
  Future tryToSetProfileInfos() async {
    final sum = SignUpViewModel.instance;
    final data = {
      'update_type': 'after_login',
      'first_name': sum.fNameController.text,
      'last_name': sum.lNameController.text,
    };

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrls.profileInfoUpdateUrl),
    );
    request.fields.addAll(data);
    request.headers.addAll(headers);

    if (sum.profileImage.value != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', sum.profileImage.value!.path),
      );
    }

    final responseData = await NetworkApiServices().postWithFileApi(
      request,
      LocalKeys.profileSetup,
    );

    if (responseData != null) {
      LocalKeys.profileSetupComplete.showToast();
      setToken(token);
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    return null;
  }

  /// Used to share the registration token with profile setup steps.
  void sToken(String newToken) {
    token = newToken;
    notifyListeners();
  }

  /// Safely converts bool / int / String / null → Dart bool.
  ///   true,  1, "1", "true"  → true
  ///   false, 0, "0", "false" → false
  ///   null or anything else  → false
  bool _parseToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    final s = value.toString().toLowerCase().trim();
    return s == '1' || s == 'true';
  }
}