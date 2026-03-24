import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/order_details_view_model/order_details_view_model.dart';
import 'package:car_service/views/order_details_view/components/order_details_address.dart';
import 'package:car_service/views/order_details_view/components/order_details_buttons.dart';
import 'package:car_service/views/order_details_view/components/order_details_cost_info.dart';
import 'package:car_service/views/order_details_view/components/order_details_outlet.dart';
import 'package:car_service/views/order_details_view/components/order_details_staff.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../services/order_services/order_details_service.dart';
import '../../utils/components/empty_widget.dart';
import 'components/order_details_booking_date.dart';
import 'components/order_details_booking_time.dart';
import 'components/order_details_items.dart';
import 'components/order_details_skeleton.dart';

class OrderDetailsView extends StatelessWidget {
  final dynamic orderId;
  const OrderDetailsView({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final odm = OrderDetailsViewModel.instance;
    return Consumer<OrderDetailsService>(
      builder: (context, od, child) {
        return Scaffold(
          backgroundColor: context.color.backgroundColor,
          appBar: AppBar(
            leading: NavigationPopIcon(backgroundColor: Colors.transparent),
            centerTitle: true,
            title: Text(LocalKeys.orderDetails),
            backgroundColor: context.color.backgroundColor,
          ),
          body: CustomRefreshIndicator(
            onRefresh: () async {
              await od.fetchOrderDetails(orderId: orderId);
            },
            refreshKey: odm.refreshKey,
            child: CustomFutureWidget(
              function: od.shouldAutoFetch(orderId)
                  ? od.fetchOrderDetails(orderId: orderId)
                  : null,
              shimmer: const OrderDetailsSkeleton1(),
              child: od.orderDetailsModel.orderDetails?.id == null
                  ? EmptyWidget(title: LocalKeys.orderNotFound)
                  : Scrollbar(
                      child: SingleChildScrollView(
                        padding: 8.paddingV,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Builder(
                          builder: (context) {
                            final order = od.orderDetailsModel.orderDetails!;
                            final isPickup =
                                order.deliveryMode?.toLowerCase() == "pickup";
                            final hasAddress = order.userLocation != null &&
                                (order.userLocation!.address ?? "").isNotEmpty;
                            return Column(
                              spacing: 12,
                              children: [
                                OrderDetailsItems(
                                  orderItems: order.items,
                                ),

                                // Show address only for home delivery with a non-empty address
                                if (!isPickup && hasAddress)
                                  OrderDetailsAddress(
                                    address: order.userLocation!,
                                  ),

                                // Show outlet for pickup, or if outlet data exists
                                if (order.outletDetails != null)
                                  OrderDetailsOutlet(
                                    outlet: order.outletDetails!,
                                  ),

                                if (order.date != null)
                                  OrderDetailsBookingDate(
                                    date: order.date!,
                                  ),

                                if (order.time != null)
                                  OrderDetailsBookingTime(
                                    time: order.time!,
                                  ),

                                if (order.staffDetails != null)
                                  OrderDetailsStaff(
                                    staff: order.staffDetails!,
                                  ),

                                OrderDetailsCostInfo(od: od),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ),
          bottomNavigationBar: od.orderDetailsModel.orderDetails?.id == null
              ? null
              : const OrderDetailsButtons(),
        );
      },
    );
  }
}