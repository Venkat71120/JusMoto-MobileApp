import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/services/booking_services/place_order_service.dart';
import 'package:car_service/utils/components/custom_preloader.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:car_service/views/landing_view/landing_view.dart';
import 'package:car_service/views/order_summery_view/components/order_summary_cost_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../utils/components/custom_future_widget.dart';
import '../order_details_view/components/order_details_address.dart';
import '../order_details_view/components/order_details_booking_date.dart';
import '../order_details_view/components/order_details_booking_time.dart';
import '../order_details_view/components/order_details_items.dart';
import '../order_details_view/components/order_details_outlet.dart';

class OrderSummeryView extends StatelessWidget {
  final Function(BuildContext context)? updateFunction;
  const OrderSummeryView({super.key, this.updateFunction});

  @override
  Widget build(BuildContext context) {
    final sbm = ServiceBookingViewModel.instance;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (sbm.paymentLoading.value) return;
        context.toUntilPage(const LandingView());
      },
      child: FutureBuilder(
        future: updateFunction != null ? updateFunction!(context) : null,
        builder: (context, snap) {
          return Scaffold(
            appBar: AppBar(
              leading: NavigationPopIcon(
                onTap: () {
                  if (sbm.paymentLoading.value) return;
                  context.toUntilPage(const LandingView());
                },
              ),
              title: Text(LocalKeys.orderSummery),
            ),
            body: ValueListenableBuilder(
              valueListenable: sbm.paymentLoading,
              builder: (context, pLoading, child) {
                return CustomFutureWidget(
                  function: updateFunction != null ? null : null,
                  isLoading: false,
                  child: Stack(
                    children: [
                      Consumer<PlaceOrderService>(
                        builder: (context, po, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                color: context.color.backgroundColor,
                                child: Column(
                                  children: [
                                    SvgAssets.addFilled.toSVGSized(
                                      80,
                                      color: context.color.primarySuccessColor,
                                    ),
                                    Text(
                                      LocalKeys.bookingSuccessful,
                                      style: context.titleLarge?.bold,
                                    ),
                                    const Row(),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    spacing: 12,
                                    children: [
                                      OrderDetailsItems(
                                        orderItems:
                                            po
                                                .orderResponseModel
                                                .orderDetails
                                                ?.items,
                                      ),
                                      if (po
                                              .orderResponseModel
                                              .orderDetails
                                              ?.userLocation !=
                                          null)
                                        OrderDetailsAddress(
                                          address:
                                              po
                                                  .orderResponseModel
                                                  .orderDetails!
                                                  .userLocation!,
                                        ),
                                      if (po
                                              .orderResponseModel
                                              .orderDetails
                                              ?.outletDetails !=
                                          null)
                                        OrderDetailsOutlet(
                                          outlet:
                                              po
                                                  .orderResponseModel
                                                  .orderDetails!
                                                  .outletDetails!,
                                        ),
                                      if (po
                                              .orderResponseModel
                                              .orderDetails
                                              ?.date !=
                                          null)
                                        OrderDetailsBookingDate(
                                          date:
                                              po
                                                  .orderResponseModel
                                                  .orderDetails!
                                                  .date!,
                                        ),
                                      if (po
                                              .orderResponseModel
                                              .orderDetails
                                              ?.time !=
                                          null)
                                        OrderDetailsBookingTime(
                                          time:
                                              po
                                                  .orderResponseModel
                                                  .orderDetails!
                                                  .time!,
                                        ),
                                      OrderSummaryCostInfo(po: po),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (pLoading)
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: context.color.accentContrastColor.withOpacity(
                            .7,
                          ),
                          child: const Center(child: CustomPreloader()),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
