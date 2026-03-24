import 'package:car_service/customizations/colors.dart';
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

  // Filter options: label → API status value (null = all)
  static const List<_FilterOption> _filters = [
    _FilterOption(label: "All", status: null),
    _FilterOption(label: "Pending", status: 0),
    _FilterOption(label: "Processing", status: 1),
    _FilterOption(label: "Completed", status: 3),
    _FilterOption(label: "Cancelled", status: 4),
  ];

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
              await ol.fetchOrderList(status: olm.selectedStatusFilter.value);
            },
            child: CustomFutureWidget(
              function: ol.shouldAutoFetch ? ol.fetchOrderList() : null,
              shimmer: const OrderListSkeleton(),
              child: Column(
                children: [
                  // ── Filter Chips ──
                  ValueListenableBuilder<int?>(
                    valueListenable: olm.selectedStatusFilter,
                    builder: (context, selectedStatus, _) {
                      return SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filters.length,
                          separatorBuilder: (_, __) => 8.toWidth,
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isSelected =
                                selectedStatus == filter.status;
                            return GestureDetector(
                              onTap: () {
                                olm.applyStatusFilter(
                                    context, filter.status);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : context
                                          .color.accentContrastColor,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: context
                                              .color.primaryBorderColor,
                                        ),
                                ),
                                child: Text(
                                  filter.label,
                                  style: context.labelSmall?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : context.color
                                            .primaryContrastColor,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  8.toHeight,
                  // ── Order List ──
                  Expanded(
                    child: ol.myOrdersModel.orders.isEmpty
                        ? EmptyWidget(title: LocalKeys.noOrdersFound)
                        : Scrollbar(
                            controller: olm.scrollController,
                            child: CustomScrollView(
                              controller: olm.scrollController,
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              slivers: [
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
                                  itemCount:
                                      ol.myOrdersModel.orders.length,
                                ),
                                24.toHeight.toSliver,
                                if (ol.nextPage != null &&
                                    !ol.nexLoadingFailed)
                                  ScrollPreloader(
                                          loading: ol.nextPageLoading)
                                      .toSliver,
                                24.toHeight.toSliver,
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        });
      }),
    );
  }
}

class _FilterOption {
  final String label;
  final int? status;
  const _FilterOption({required this.label, required this.status});
}
