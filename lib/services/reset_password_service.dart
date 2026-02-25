import 'package:flutter/material.dart';
import '../../helper/extension/string_extension.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';

class ResetPasswordService with ChangeNotifier {
  resetPassword(BuildContext context, email, password, otp) async {
    final data = {
      'token': '$otp',
      'password': password,
      'password_confirmation': password,
    };

    final responseData = await NetworkApiServices().postApi(
        data, AppUrls.resetPasswordUrl, LocalKeys.resetPassword,
        headers: acceptJsonHeader);

    if (responseData != null) {
      LocalKeys.passwordResetSuccessful.showToast();
      return true;
    } else {}
  }
}
