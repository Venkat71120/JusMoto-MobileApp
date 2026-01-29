import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';

class ChatCredentialService with ChangeNotifier {
  var appId = "";
  var appKey = "";
  var appSecret = "";
  var appCluster = "";

  initLocal() {
    final localData = sPref?.getString("chat_credentials");
    fetchCredentials();
    if ((localData ?? "").isEmpty) {
      fetchCredentials();
      return;
    }
    try {
      final processedData = jsonDecode(localData!);
      appId = processedData["pusher_app_id"] ?? "";
      appKey = processedData["pusher_app_key"] ?? "";
      appSecret = processedData["pusher_app_secret"] ?? "";
      appCluster = processedData["pusher_app_cluster"] ?? "";
    } catch (e) {
      fetchCredentials();
    }
  }

  fetchCredentials() async {
    var url = AppUrls.chatCredentialUrl;

    final responseData = await NetworkApiServices().getApi(
      url,
      null,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      appId = responseData["pusher_app_id"] ?? "";
      appKey = responseData["pusher_app_key"] ?? "";
      appSecret = responseData["pusher_app_secret"] ?? "";
      appCluster = responseData["pusher_app_cluster"] ?? "";
      sPref?.setString("chat_credentials", jsonEncode(responseData));
      return true;
    }
  }
}
