import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/view_models/change_password_view_model/change_password_view_model.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/local_keys.g.dart';

class ChangePasswordService {
  tryChangingPassword() async {
    final cpm = ChangePasswordViewModel.instance;

    final data = {
      'current_password': cpm.currentPassController.text,
      'new_password': cpm.newPassController.text
    };
    debugPrint(acceptJsonAuthHeader.toString());
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.changePasswordUrl,
      LocalKeys.changePassword,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      LocalKeys.passwordChangedSuccessfully.showToast();
      return true;
    }
  }
}
