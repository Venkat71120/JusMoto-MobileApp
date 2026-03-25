import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/home_services/unread_count_service.dart';

import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/notification_models/notification_list_model.dart';

class NotificationListService with ChangeNotifier {
  NotificationListModel? _notificationListModel;
  NotificationListModel get notificationListModel =>
      _notificationListModel ?? NotificationListModel(notifications: []);
  var token = "";

  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool get shouldAutoFetch => _notificationListModel == null || token.isInvalid;

  fetchNotificationList() async {
    token = getToken;
    final url = AppUrls.myNotificationsListUrl;
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.orderList, headers: commonAuthHeader);

    if (responseData != null) {
      _notificationListModel = NotificationListModel.fromJson(responseData);
      nextPage = _notificationListModel?.pagination?.nextPageUrl;
      // Sync badge count with actual unread notifications from the list
      final unreadCount = _notificationListModel?.notifications
              .where((n) => !n.isRead)
              .length ??
          0;
      UnreadCountService.instance.notificationCount.value = unreadCount;
    } else {}
    notifyListeners();
  }

  markAsReadLocally(id) {
    if (_notificationListModel == null) return;
    final index = _notificationListModel!.notifications
        .indexWhere((element) => element.id == id);
    if (index != -1) {
      final oldNotification = _notificationListModel!.notifications[index];
      _notificationListModel!.notifications[index] = NotificationModel(
        id: oldNotification.id,
        identity: oldNotification.identity,
        userId: oldNotification.userId,
        type: oldNotification.type,
        title: oldNotification.title,
        message: oldNotification.message,
        isRead: true,
        data: oldNotification.data,
        createdAt: oldNotification.createdAt,
      );
      notifyListeners();
    }
  }

  fetchNextPage() async {
    token = getToken;
    if (nextPageLoading) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData = await NetworkApiServices()
        .getApi(nextPage, LocalKeys.orderList, headers: commonAuthHeader);

    if (responseData != null) {
      final tempData = NotificationListModel.fromJson(responseData);
      for (var element in tempData.notifications) {
        _notificationListModel?.notifications.add(element);
      }
      nextPage = tempData.pagination?.nextPageUrl;
    } else {
      nexLoadingFailed = true;
      Future.delayed(const Duration(seconds: 1)).then((value) {
        nexLoadingFailed = false;
        notifyListeners();
      });
    }
    nextPageLoading = false;
    notifyListeners();
  }
}
