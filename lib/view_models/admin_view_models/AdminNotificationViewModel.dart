import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminNotificationService.dart';
import '../../models/admin_models/AdminNotificationModels.dart';

class AdminNotificationViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminNotificationViewModel(this.context);

  void init() {
    final service = Provider.of<AdminNotificationService>(context, listen: false);
    service.fetchNotifications(page: 1);
  }

  void loadMore() {
    final service = Provider.of<AdminNotificationService>(context, listen: false);
    final pagination = service.notificationList.pagination;
    if (pagination != null && pagination.hasNextPage) {
      service.fetchNotifications(page: pagination.page + 1);
    }
  }

  Future<void> markAsRead(AdminNotificationItem notification) async {
    final service = Provider.of<AdminNotificationService>(context, listen: false);
    await service.markAsRead(notification.id);
  }
}
