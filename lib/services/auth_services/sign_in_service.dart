import 'dart:convert';
import 'package:flutter/material.dart';

import '../../customization.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';

/// Signs in regular users via email/password or social providers.
/// Backend wraps all responses in: { success, message, data: { user, token } }
class SignInService with ChangeNotifier {
  bool emailVerified = true;
  bool verifyEnabled = true;
  var emailToken = "";
  var token = "";
  var email = "";
  var userId = "";
  String? firstName;

  Future trySignIn({
    required String emailUsername,
    required String password,
  }) async {
    final Map<String, dynamic> data = {
      'email': emailUsername, // backend accepts email OR username in this field
      'password': password,
      // NOTE: backend /auth/login does NOT require user_type — removed
    };

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final responseData = await NetworkApiServices().postApi(
      jsonEncode(data),
      AppUrls.signInUrl,
      LocalKeys.signIn,
      headers: headers,
    );

    // Backend response shape: { success, message, data: { user: {...}, token: "..." } }
    if (responseData != null && responseData['data'] != null) {
      final dataObj = responseData['data'];
      final user = dataObj['user'];

      token = dataObj['token'] ?? "";
      email = user['email'] ?? "";
      firstName = user['first_name'];
      userId = user['id']?.toString() ?? "";

      // These fields may not exist on the new backend — default to verified/disabled
      verifyEnabled =
          (responseData['verify_enabled'] ?? false).toString().parseToBool;
      emailVerified = (user['email_verified'] ?? 1).toString().parseToBool;
      emailToken = user['email_verify_token']?.toString() ?? "";

      return emailVerified || !verifyEnabled;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    return null;
  }

  /// Social login — Google, Facebook, Apple.
  /// Backend expects: provider, email, firstName, lastName, socialId, (optional) image
  Future trySocialSignIn({
    required String type, // "google" | "facebook" | "apple"
    required String fName,
    required String lName,
    required String email,
    required String id,
    String? image,
  }) async {
    final data = {
      'provider': type, // ✅ correct field name per backend docs
      'email': email,
      'firstName': fName, // ✅ camelCase per backend docs
      'lastName': lName, // ✅ camelCase per backend docs
      'socialId': id, // ✅ correct field name per backend docs
      if (image != null) 'image': image,
    };

    final headers = {
      'Accept': 'application/json',
      'secretKey': socialSignInKey,
    };

    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.socialSignInUrl,
      LocalKeys.signInWithGoogle,
      headers: headers,
    );

    // Backend response shape: { success, message, data: { user: {...}, token: "..." } }
    if (responseData != null && responseData['data'] != null) {
      final dataObj = responseData['data'];
      token = dataObj['token'] ?? "";
      setToken(token); // persist to SharedPreferences
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
      return false;
    }

    return false;
  }
}
