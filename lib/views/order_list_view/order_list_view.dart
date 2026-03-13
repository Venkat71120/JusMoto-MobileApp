import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/order_services/order_list_service.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/scrolling_preloader.dart';
import 'package:car_service/view_models/order_list_view_model/order_list_view_model.dart';
import 'package:car_service/views/account_skeleton/account_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/order_list_skeleton.dart';
import 'components/order_list_tile.dart';

class OrderListView extends StatelessWidget {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final olm = OrderListViewModel.instance;
    olm.scrollController.addListener(() {
      olm.tryToLoadMore(context);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalKeys.orderList),
        centerTitle: true,
        backgroundColor: context.color.backgroundColor,
      ),
      body: Consumer<ProfileInfoService>(builder: (context, pi, child) {
        if (pi.profileInfoModel.userDetails == null) {
          return const AccountSkeleton();
        }
        return Consumer<OrderListService>(builder: (context, ol, child) {
          return CustomRefreshIndicator(
            onRefresh: () async {
              await ol.fetchOrderList();
            },
            child: CustomFutureWidget(
              function: ol.shouldAutoFetch ? ol.fetchOrderList() : null,
              shimmer: const OrderListSkeleton(),
              child: ol.myOrdersModel.orders.isEmpty
                  ? EmptyWidget(title: LocalKeys.noOrdersFound)
                  : Scrollbar(
                      controller: olm.scrollController,
                      child: ValueListenableBuilder(
                          valueListenable: olm.statusType,
                          builder: (context, value, child) {
                            return CustomScrollView(
                              controller: olm.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                8.toHeight.toSliver,
                                SliverList.separated(
                                  itemBuilder: (context, index) {
                                    final order =
                                        ol.myOrdersModel.orders[index];
                                    return OrderListTile(
                                      order: order,
                                      index: index,
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      16.toHeight,
                                  itemCount: ol.myOrdersModel.orders.length,
                                ),
                                24.toHeight.toSliver,
                                if (ol.nextPage != null && !ol.nexLoadingFailed)
                                  ScrollPreloader(loading: ol.nextPageLoading)
                                      .toSliver,
                                24.toHeight.toSliver,
                              ],
                            );
                          }),
                    ),
            ),
          );
        });
      }),
    );
  }
}
