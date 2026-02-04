import 'package:flutter/material.dart';

import '../../customization.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';

class SignInService with ChangeNotifier {
  bool emailVerified = true;
  bool verifyEnabled = true;
  var emailToken = "";
  var token = "";
  var email = "";
  var userId = "";
  String? firstName;
  
  Future trySignIn(
      {required String emailUsername, required String password}) async {
    final data = {
      'email': emailUsername,
      'password': password,
      "user_type": "1",
    };
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.signInUrl,
      LocalKeys.signIn,
    );

    if (responseData != null && responseData.containsKey("token")) {
      LocalKeys.signedInSuccessfully.showToast();
      token = responseData["token"] ?? "";
      verifyEnabled = responseData["verify_enabled"].toString().parseToBool;
      emailVerified =
          responseData["user"]["email_verified"].toString().parseToBool;
      emailToken = responseData["user"]["email_verify_token"]?.toString() ?? "";
      email = responseData["user"]["email"] ?? "";
      firstName = responseData["user"]["first_name"];
      userId = responseData["user"]["id"]?.toString() ?? "";
      return emailVerified || !verifyEnabled;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }
  }

  trySocialSignIn({
    required String type,
    required String fName,
    required String lName,
    required String email,
    required String id,
  }) async {
    print('📡 Sending social sign-in request to backend');
    print('  - URL: ${AppUrls.socialSignInUrl}');
    print('  - Type: $type');
    print('  - Email: $email');
    print('  - First Name: $fName');
    print('  - Last Name: $lName');
    print('  - ID: $id');
    
    final url = AppUrls.socialSignInUrl;

    final data = {
      'email': email,
      'source': type,
      'firstname': fName,
      'lastname': lName,
      "user_type": "1",  // ⚠️ IMPORTANT: This was missing in your second version!
      'is_go_fb_ap_id': id
    };

    final headers = {
      'Accept': 'application/json',
      'secretKey': socialSignInKey
    };

    print('📦 Request data: $data');
    print('📋 Request headers: ${headers.keys.toList()}');

    final responseData = await NetworkApiServices()
        .postApi(data, url, LocalKeys.signInWithGoogle, headers: headers);

    print('📥 Response received: $responseData');

    if (responseData != null) {
      if (responseData.containsKey("token")) {
        print('✓ Token received: ${responseData["token"]?.toString().substring(0, 20)}...');
        setToken(responseData["token"]);
        return true;
      } else if (responseData.containsKey("message")) {
        print('⚠️ Server message: ${responseData["message"]}');
        responseData["message"]?.toString().showToast();
        return false;
      } else {
        print('⚠️ Unexpected response structure: $responseData');
        return false;
      }
    } else {
      print('❌ Response is null');
      return false;
    }
  }
}