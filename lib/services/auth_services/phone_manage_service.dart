import 'dart:async';

import 'package:car_service/helper/constant_helper.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';

class PhoneManageService with ChangeNotifier {
  String? otp;
  String? phone;
  Timer? timer;
  bool loadingSendOTP = false;
  bool phoneVerifyLoading = false;

  bool canSend = false;
  Future tryOtpToPhone({
    String? phone,
  }) async {
    this.phone = phone ?? "";
    final data = {
      'phone': this.phone,
    };
    loadingSendOTP = true;
    notifyListeners();
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.sentOtpToPhoneUrl,
      LocalKeys.signIn,
    );

    if (responseData != null) {
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

  Future trySendingOtpToNewPhone({
    String? phone,
  }) async {
    this.phone = phone ?? "";
    final data = {
      'phone': this.phone,
    };
    loadingSendOTP = true;
    notifyListeners();
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.changePhoneUrl,
      LocalKeys.signUp,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
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

  Future tryPhoneVerify({
    required String phone,
    required String userId,
    required String token,
  }) async {
    phone = phone;
    final data = {
      'phone_verified': "1",
      "user_id": userId.toString(),
    };
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final responseData = await NetworkApiServices().postApi(
        data, AppUrls.verifyPhoneUrl, LocalKeys.signUp,
        headers: headers);
    if (responseData != null) {
      otp = responseData["otp"];
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }
  }

  Future tryPhoneChange({
    required String otp,
  }) async {
    final data = {
      'phone': phone,
      'otp_verify_status': '1',
      'otp': otp,
    };
    phoneVerifyLoading = true;
    notifyListeners();
    final responseData = await NetworkApiServices().postApi(
        data, AppUrls.changePhoneUrl, LocalKeys.changePhone,
        headers: acceptJsonAuthHeader);
    if (responseData != null) {
      LocalKeys.changedPhoneSuccessfully.showToast();
      phoneVerifyLoading = false;
      notifyListeners();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    phoneVerifyLoading = false;
    notifyListeners();
  }

  Future tryPhoneSignIn({
    required String otp,
  }) async {
    final data = {
      'phone': phone,
      'otp_verify_status': '1',
      'otp': otp,
      "user_type": "1",
    };
    phoneVerifyLoading = true;
    notifyListeners();
    final responseData = await NetworkApiServices()
        .postApi(data, AppUrls.otpSignInUrl, LocalKeys.signIn);
    if (responseData != null) {
      LocalKeys.signedInSuccessfully.showToast();
      phoneVerifyLoading = false;
      final token = responseData["token"];
      setToken(token);
      setLoginTimestamp();
      notifyListeners();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }

    phoneVerifyLoading = false;
    notifyListeners();
  }

  void setResetTimer() {
    loadingSendOTP = false;
    canSend = true;
  }
}
