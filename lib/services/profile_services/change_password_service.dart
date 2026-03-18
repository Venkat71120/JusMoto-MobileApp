import 'dart:convert';

import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/view_models/change_password_view_model/change_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../helper/app_urls.dart';
import '../../helper/local_keys.g.dart';

class ChangePasswordService {
  tryChangingPassword() async {
    final cpm = ChangePasswordViewModel.instance;

    final data = {
      'current_password': cpm.currentPassController.text,
      'new_password': cpm.newPassController.text,
      'confirm_password': cpm.newPassController.text,
    };

    try {
      final response = await http.put(
        Uri.parse(AppUrls.changePasswordUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $getToken',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      debugPrint(response.body);
      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          LocalKeys.passwordChangedSuccessfully.showToast();
          return true;
        } else {
          (responseData['message'] ?? 'Failed to change password')
              .toString()
              .showToast();
        }
      } else {
        final responseData = jsonDecode(response.body);
        (responseData['message'] ?? 'Failed to change password')
            .toString()
            .showToast();
      }
    } catch (e) {
      debugPrint(e.toString());
      LocalKeys.changePassword.showToast();
    }
  }
}
