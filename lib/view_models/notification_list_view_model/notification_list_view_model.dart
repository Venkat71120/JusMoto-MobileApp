import 'package:car_service/services/notification_services/notification_list_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationListViewModel {
  ScrollController scrollController = ScrollController();
  NotificationListViewModel._init();
  static NotificationListViewModel? _instance;
  static NotificationListViewModel get instance {
    _instance ??= NotificationListViewModel._init();
    return _instance!;
  }

  NotificationListViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  tryToLoadMore(BuildContext context) {
    try {
      final nl = Provider.of<NotificationListService>(context, listen: false);
      final nextPage = nl.nextPage;
      final nextPageLoading = nl.nextPageLoading;

      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (nextPage != null && !nextPageLoading) {
          nl.fetchNextPage();
          return;
        }
      }
    } catch (e) {}
  }
}
