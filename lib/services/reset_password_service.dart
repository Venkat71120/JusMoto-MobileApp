import 'package:flutter/material.dart';
import '../../helper/extension/string_extension.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';

class ResetPasswordService with ChangeNotifier {
  resetPassword(BuildContext context, email, password, otp) async {
    final data = {
      'email': '$email',
      'otp': '$otp',
      'password': password,
      'confirm_password': password,
    };

    final responseData = await NetworkApiServices().postApi(
        data, AppUrls.resetPasswordUrl, LocalKeys.resetPassword,
        headers: commonAuthHeader);

    if (responseData != null) {
      LocalKeys.passwordResetSuccessful.showToast();
      return true;
    } else {}
  }
}
