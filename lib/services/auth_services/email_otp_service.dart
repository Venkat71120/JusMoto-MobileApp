import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import './../../helper/constant_helper.dart';

class EmailManageService with ChangeNotifier {
  String? otp;
  String? email;
  Timer? timer;
  bool loadingSendOTP = false;
  bool loadingVerify = false;

  bool canSend = false;
  Future tryOtpToEmail({required String emailUsername}) async {
    email = emailUsername;
    final data = {'email': emailUsername};
    loadingSendOTP = true;
    notifyListeners();
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.sentOtpToMailUrl,
      LocalKeys.signUp,
    );
    if (responseData != null) {
      otp = responseData["otp"]?.toString();
      canSend = false;
      LocalKeys.otpSendToMailSuccessfully.showToast();
      timer = Timer(const Duration(seconds: 120), () {
        canSend = true;
        notifyListeners();
      });
      loadingSendOTP = false;
      notifyListeners();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }
  }

  Future tryOtpToNewEmail({String? emailUsername}) async {
    if (emailUsername != null) {
      email = emailUsername;
    }
    final data = {'email': emailUsername ?? email ?? ""};
    loadingSendOTP = true;
    notifyListeners();
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.changeEmailUrl,
      LocalKeys.signUp,
      headers: acceptJsonAuthHeader,
    );
    if (responseData != null) {
      otp = responseData["otp"]?.toString();
      canSend = false;
      LocalKeys.otpSendToMailSuccessfully.showToast();
      timer = Timer(const Duration(seconds: 120), () {
        canSend = true;
        notifyListeners();
      });
      loadingSendOTP = false;
      notifyListeners();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }
  }

  Future tryEmailVerify({
    required String emailUsername,
    required String userId,
    required String token,
  }) async {
    email = emailUsername;
    final data = {'email_verified': "1", "user_id": userId.toString()};
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.verifyEmailUrl,
      LocalKeys.signUp,
      headers: headers,
    );
    if (responseData != null) {
      otp = responseData["otp"];
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }
  }

  Future tryEmailChange({required otp}) async {
    final data = {'email': email, 'email_verified': '1', 'otp': '$otp'};
    loadingVerify = true;
    notifyListeners();
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.changeEmailUrl,
      LocalKeys.changeEmail,
      headers: acceptJsonAuthHeader,
    );
    if (responseData != null && responseData.containsKey("token")) {
      otp = responseData["otp"];
      LocalKeys.changedEmailSuccessfully.showToast();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }
    loadingVerify = false;
    notifyListeners();
  }

  void setResetTimer() {
    loadingSendOTP = false;
    canSend = true;
  }
}
