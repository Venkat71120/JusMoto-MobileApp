import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/services/notification_services/notification_list_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_preloader.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/scrolling_preloader.dart';
import 'package:car_service/view_models/notification_list_view_model/notification_list_view_model.dart';
import 'package:car_service/views/notification_list_view/components/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../account_skeleton/account_skeleton.dart';

class NotificationListView extends StatelessWidget {
  const NotificationListView({super.key});

  @override
  Widget build(BuildContext context) {
    final nlm = NotificationListViewModel.instance;
    final nlProvider =
        Provider.of<NotificationListService>(context, listen: false);
    nlm.scrollController.addListener(() {
      nlm.tryToLoadMore(context);
    });
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.notifications),
      ),
      body: Consumer<ProfileInfoService>(builder: (context, pi, child) {
        if (pi.profileInfoModel.userDetails == null) {
          return const AccountSkeleton();
        }
        return CustomRefreshIndicator(
          onRefresh: () async {
            await nlProvider.fetchNotificationList();
          },
          child: Scrollbar(
            controller: nlm.scrollController,
            child: CustomFutureWidget(
              function: nlProvider.shouldAutoFetch
                  ? nlProvider.fetchNotificationList()
                  : null,
              shimmer: const CustomPreloader(),
              child: Consumer<NotificationListService>(
                  builder: (context, nl, child) {
                return nl.notificationListModel.notifications.isEmpty
                    ? EmptyWidget(title: LocalKeys.na)
                    : CustomScrollView(
                        controller: nlm.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          const SizedBox().divider.toSliver,
                          SliverList.separated(
                            itemBuilder: (context, index) {
                              final notification =
                                  nl.notificationListModel.notifications[index];
                              return NotificationTile(
                                notification: notification,
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox().divider,
                            itemCount:
                                nl.notificationListModel.notifications.length,
                          ),
                          16.toHeight.toSliver,
                          if (nl.nextPage != null && !nl.nexLoadingFailed)
                            ScrollPreloader(loading: nl.nextPageLoading)
                                .toSliver,
                          16.toHeight.toSliver,
                        ],
                      );
              }),
            ),
          ),
        );
      }),
    );
  }
}
