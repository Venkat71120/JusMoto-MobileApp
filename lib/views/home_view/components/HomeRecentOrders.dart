import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/order_services/order_list_service.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/views/order_list_view/components/order_list_tile.dart';
import 'package:car_service/views/order_list_view/order_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_service/customizations/colors.dart';

class HomeRecentOrders extends StatelessWidget {
  const HomeRecentOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileInfoService>(
      builder: (context, pi, child) {
        // Don't show if user is not logged in
        if (pi.profileInfoModel.userDetails == null) {
          return const SizedBox.shrink();
        }

        return Consumer<OrderListService>(
          builder: (context, ol, child) {
            return CustomFutureWidget(
              function: ol.shouldAutoFetch ? ol.fetchOrderList() : null,
              shimmer: const SizedBox.shrink(),
              child: ol.myOrdersModel.orders.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.toHeight,
                        // Header with title and See All button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FieldLabel(label: LocalKeys.recentOrders),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OrderListView(),
                                  ),
                                );
                              },
                              child: Text(
                                LocalKeys.seeAll,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ).hp20,
                        12.toHeight,
                        // Display only first 2 orders
                        ...ol.myOrdersModel.orders
                            .take(2)
                            .map((order) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: OrderListTile(order: order),
                                ))
                            .toList(),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}