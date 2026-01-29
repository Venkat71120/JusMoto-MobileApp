import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../data/network/network_api_services.dart';
import '../helper/app_urls.dart';
import '../helper/constant_helper.dart';

class PushNotificationService {
  String? userToken;

  setUserToken(value) {
    userToken = value;
  }

  updateDeviceToken({bool forceUpdate = false}) async {
    String? localToken = sPref?.getString("device_token") ?? "";

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    final String? uToken;
    if (Platform.isIOS) {
      await messaging.getAPNSToken();
      uToken = await messaging.getToken();
    } else {
      uToken = await messaging.getToken();
    }

    if (uToken == localToken && !forceUpdate) {
      return;
    }
    setUserToken(userToken);
    sPref?.setString("device_token", userToken ?? uToken ?? "");
    final data = {"firebase_token": userToken ?? uToken ?? ""};
    debugPrint(data.toString());
    final responseData = await NetworkApiServices().postApi(
      data,
      AppUrls.fcmTokenUrl,
      null,
      headers: acceptJsonAuthHeader,
    );
    debugPrint(responseData.toString());
    if (responseData != null) {
      sPref?.setString("device_token", userToken ?? uToken ?? "");
    }
  }
}
