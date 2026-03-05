import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';

class UnreadCountService {
  final ValueNotifier<num> notificationCount = ValueNotifier(0);
  final ValueNotifier<num> messageCount = ValueNotifier(0);

  UnreadCountService._init();
  static UnreadCountService? _instance;
  static UnreadCountService get instance {
    _instance ??= UnreadCountService._init();
    return _instance!;
  }

  UnreadCountService._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  fetchUnreadCounts() async {
    var url = AppUrls.unreadCountUrl;

    final responseData = await NetworkApiServices().getApi(
      url,
      null,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      debugPrint(responseData.toString());
      if (responseData["data"] != null && responseData["data"] is Map) {
        notificationCount.value = responseData["data"]["count"] ?? 0;
      } else {
        notificationCount.value =
            responseData["unread_notifications"].toString().tryToParse;
        messageCount.value =
            (responseData["unseen_message"]?["client_unseen_message_count"])
                .toString()
                .tryToParse;
      }
      return true;
    }
  }
}
