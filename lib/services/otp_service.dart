import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../view_models/reset_password_model/reset_password_model.dart';

class OtpService with ChangeNotifier {
  String? otpCode;
  bool loadingSendOTP = false;
  DateTime? otpSentTime;

  Timer? sendAgainOptionTimer;

  setLoadingSendOTP(value) {
    loadingSendOTP = value;
    notifyListeners();
  }

  Future sendOTP(BuildContext context, email, token) async {
    setLoadingSendOTP(true);
    try {
      final data = {
        'email': email ?? '',
      };
      debugPrint(AppUrls.sendOtpUrl.toString());
      final responseData = await NetworkApiServices().postApi(
          data, AppUrls.sendOtpUrl, LocalKeys.sendingOtpToMail,
          headers: acceptJsonHeader);

      if (responseData != null) {
        setSentTime();
        setLoadingSendOTP(false);
        if (responseData.containsKey("otp")) {
          print(responseData['otp']);
        }
        otpCode = responseData['otp'];
        return responseData['otp'];
      } else {}
    } finally {
      setLoadingSendOTP(false);
    }
  }

  Future sendOTPWithoutToken(BuildContext context, email) async {
    setLoadingSendOTP(true);

    try {
      final rpm = ResetPasswordViewModel.instance;
      final data = {
        'email': email ?? rpm.emailController.text,
      };

      final responseData = await NetworkApiServices()
          .postApi(data, AppUrls.sendOtpUrl, LocalKeys.sendingOtpToMail);
      if (responseData != null) {
        setSentTime();
        setLoadingSendOTP(false);
        debugPrint(responseData['otp'].toString());
        otpCode = responseData['otp'];
        return responseData['otp'];
      }
    } finally {
      setLoadingSendOTP(false);
    }
  }

  void setSentTime() {
    sendAgainOptionTimer?.cancel();
    otpSentTime = DateTime.now();
    sendAgainOptionTimer = Timer(const Duration(seconds: 30), () {
      sendAgainOptionTimer = null;
      notifyListeners();
    });
  }
}
