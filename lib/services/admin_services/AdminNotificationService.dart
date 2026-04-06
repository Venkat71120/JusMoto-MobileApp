import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/AdminNotificationModels.dart';
import '../../helper/extension/string_extension.dart';

class AdminNotificationService extends ChangeNotifier {
  AdminNotificationListModel _notificationList = AdminNotificationListModel.empty();
  AdminNotificationListModel get notificationList => _notificationList;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchNotifications({int page = 1}) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().getApi(
        '${AppUrls.adminNotificationsUrl}?page=$page&limit=15',
        "Admin Notifications List",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        final newList = AdminNotificationListModel.fromJson(Map<String, dynamic>.from(response));
        if (page == 1) {
          _notificationList = newList;
        } else {
          _notificationList = AdminNotificationListModel(
            data: [..._notificationList.data, ...newList.data],
            pagination: newList.pagination,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching notifications: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(int id) async {
    try {
      final response = await NetworkApiServices().putApi(
        {},
        '${AppUrls.adminNotificationsUrl}/$id/read',
        "Mark Notification as Read",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        // Local update
        final index = _notificationList.data.indexWhere((n) => n.id == id);
        if (index != -1) {
          // Since it's final in the model, we could just refresh or define copyWith
          // Re-fetching current page is safer for data consistency
          fetchNotifications(page: _notificationList.pagination?.page ?? 1);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      return false;
    }
  }
}
