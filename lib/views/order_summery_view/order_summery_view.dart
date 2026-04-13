import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/booking_services/place_order_service.dart';
import 'package:car_service/utils/components/custom_preloader.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:car_service/views/landing_view/landing_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../models/order_models/order_response_model.dart';
import '../../customizations/colors.dart';
import '../../helper/local_keys.g.dart';
import '../../helper/svg_assets.dart';
import '../invoice_view/invoice_view.dart' show downloadInvoicePdf;
import '../../utils/components/custom_future_widget.dart';
import '../../utils/components/custom_network_image.dart';
import '../../utils/components/custom_squircle_widget.dart';
import '../../utils/components/info_tile.dart';

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
            backgroundColor: context.color.backgroundColor,
            appBar: AppBar(
              leading: NavigationPopIcon(
                onTap: () {
                  if (sbm.paymentLoading.value) return;
                  context.toUntilPage(const LandingView());
                },
              ),
              title: Text(LocalKeys.orderSummery),
              centerTitle: true,
              backgroundColor: context.color.backgroundColor,
              elevation: 0,
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
                          if (po.orderResponseModel.orderDetails == null) {
                            return const SizedBox();
                          }
                          final order = po.orderResponseModel.orderDetails!;
                          final isPaid = ["complete", "1"]
                              .contains(order.paymentStatus);
                          final isPickup =
                              order.deliveryMode?.toLowerCase() == "pickup";

                          return Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: Column(
                                    children: [
                                      // ── Bill Card ──
                                      SquircleContainer(
                                        width: double.infinity,
                                        color:
                                            context.color.accentContrastColor,
                                        radius: 16,
                                        child: Column(
                                          children: [
                                            // ── Header with Lottie ──
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              decoration: BoxDecoration(
                                                color: isPaid
                                                    ? context.color
                                                        .primarySuccessColor
                                                        .withOpacity(0.08)
                                                    : context.color
                                                        .primaryPendingColor
                                                        .withOpacity(0.08),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight:
                                                      Radius.circular(16),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 64,
                                                    width: 64,
                                                    decoration: BoxDecoration(
                                                      color: context.color
                                                          .primarySuccessColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.check_rounded,
                                                      size: 36,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  8.toHeight,
                                                  Text(
                                                    LocalKeys
                                                        .bookingSuccessful,
                                                    style: context
                                                        .titleLarge?.bold,
                                                  ),
                                                  if (order.invoiceNumber !=
                                                      null) ...[
                                                    4.toHeight,
                                                    Text(
                                                      "#${order.invoiceNumber}",
                                                      style: context.bodySmall
                                                          ?.copyWith(
                                                        color: context.color
                                                            .tertiaryContrastColo,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),

                                            // ── Tear line ──
                                            _buildTearLine(context),

                                            // ── Items Section ──
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Items",
                                                    style: context
                                                        .titleSmall?.bold6,
                                                  ),
                                                  8.toHeight,
                                                  ...(order.items ?? [])
                                                      .map((item) =>
                                                          _buildItemTile(
                                                              context, item)),
                                                ],
                                              ),
                                            ),

                                            // ── Divider ──
                                            Divider(
                                              color: context
                                                  .color.primaryBorderColor,
                                              height: 1,
                                              indent: 16,
                                              endIndent: 16,
                                            ),

                                            // ── Service Mode ──
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isPickup
                                                        ? Icons.store_rounded
                                                        : Icons
                                                            .home_repair_service_rounded,
                                                    size: 18,
                                                    color: primaryColor,
                                                  ),
                                                  8.toWidth,
                                                  Text(
                                                    "Service Mode",
                                                    style: context
                                                        .bodySmall?.bold5,
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      isPickup
                                                          ? "Visit Outlet"
                                                          : "Home Pickup",
                                                      style: context.labelSmall
                                                          ?.copyWith(
                                                        color: primaryColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // ── Address ──
                                            if (!isPickup && order.userLocation != null)
                                              _buildInfoRow(
                                                context,
                                                icon: Icons.location_on_rounded,
                                                label: LocalKeys.address,
                                                value:
                                                    order.userLocation!.address ??
                                                        "---",
                                              ),

                                            // ── Outlet ──
                                            if (isPickup)
                                              _buildInfoRow(
                                                context,
                                                icon: Icons.storefront_rounded,
                                                label: LocalKeys.outlet,
                                                value:
                                                    order.outletDetails?.address ??
                                                        order.outletDetails?.outletName ??
                                                        sbm.selectedOutlet.value?.address ??
                                                        sbm.selectedOutlet.value?.outletName ??
                                                        "---",
                                              ),

                                            // ── Date & Time ──
                                            if (order.date != null ||
                                                order.time != null)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 6),
                                                child: Row(
                                                  children: [
                                                    if (order.date != null)
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .calendar_today_rounded,
                                                              size: 16,
                                                              color:
                                                                  primaryColor,
                                                            ),
                                                            8.toWidth,
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    LocalKeys
                                                                        .date,
                                                                    style: context
                                                                        .bodySmall
                                                                        ?.bold5
                                                                        .copyWith(
                                                                      fontSize:
                                                                          11,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    DateFormat("dd MMM yyyy")
                                                                        .format(
                                                                            order.date!),
                                                                    style: context
                                                                        .titleSmall
                                                                        ?.bold,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (order.time != null)
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .access_time_rounded,
                                                              size: 16,
                                                              color:
                                                                  primaryColor,
                                                            ),
                                                            8.toWidth,
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    LocalKeys
                                                                        .time,
                                                                    style: context
                                                                        .bodySmall
                                                                        ?.bold5
                                                                        .copyWith(
                                                                      fontSize:
                                                                          11,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    order.time!,
                                                                    style: context
                                                                        .titleSmall
                                                                        ?.bold,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),

                                            12.toHeight,

                                            // ── Tear line ──
                                            _buildTearLine(context),

                                            // ── Price Breakdown ──
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Price Breakdown",
                                                    style: context
                                                        .titleSmall?.bold6,
                                                  ),
                                                  12.toHeight,
                                                  InfoTile(
                                                    title: LocalKeys.subtotal,
                                                    value:
                                                        order.subTotal.cur,
                                                  ),
                                                  10.toHeight,
                                                  InfoTile(
                                                    title: LocalKeys.vat,
                                                    value: order.tax.cur,
                                                  ),
                                                  10.toHeight,
                                                  InfoTile(
                                                    title: LocalKeys
                                                        .deliveryCharge,
                                                    value: order
                                                        .deliveryCharge.cur,
                                                  ),
                                                  10.toHeight,
                                                  InfoTile(
                                                    title: LocalKeys.discount,
                                                    value:
                                                        "- ${order.couponAmount.cur}",
                                                    valueColor: order
                                                                .couponAmount >
                                                            0
                                                        ? context.color
                                                            .primarySuccessColor
                                                        : null,
                                                  ),
                                                  Divider(
                                                    color: context.color
                                                        .primaryBorderColor,
                                                    height: 24,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          LocalKeys.total,
                                                          style: context
                                                              .titleMedium
                                                              ?.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        order.total.cur,
                                                        style: context
                                                            .titleMedium?.bold
                                                            .price.copyWith(
                                                          color: primaryColor,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // ── Tear line ──
                                            _buildTearLine(context),

                                            // ── Payment & Order Status ──
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              child: Column(
                                                children: [
                                                  // Payment gateway
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          LocalKeys
                                                              .paymentGateway,
                                                          style: context
                                                              .bodySmall
                                                              ?.bold5,
                                                        ),
                                                      ),
                                                      Text(
                                                        order.paymentGateway
                                                                ?.replaceAll(
                                                                    "_", " ")
                                                                .capitalize ??
                                                            "---",
                                                        style: context
                                                            .titleSmall?.bold,
                                                      ),
                                                    ],
                                                  ),
                                                  12.toHeight,
                                                  // Payment status
                                                  if (!["4", "5"].contains(
                                                      order.status
                                                          .toString()))
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 12),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              LocalKeys
                                                                  .paymentStatus,
                                                              style: context
                                                                  .bodySmall
                                                                  ?.bold5,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: order
                                                                  .paymentStatus
                                                                  .toString()
                                                                  .getPaymentMutedStatusColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Text(
                                                              order
                                                                  .paymentStatus
                                                                  .toString()
                                                                  .getPaymentStatus,
                                                              style: context
                                                                  .labelSmall
                                                                  ?.copyWith(
                                                                color: order
                                                                    .paymentStatus
                                                                    .toString()
                                                                    .getPaymentPrimaryStatusColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  // Order status
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          LocalKeys
                                                              .orderStatus,
                                                          style: context
                                                              .bodySmall
                                                              ?.bold5,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: order.status
                                                              .toString()
                                                              .getOrderMutedStatusColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20),
                                                        ),
                                                        child: Text(
                                                          order.status
                                                              .toString()
                                                              .getOrderStatus,
                                                          style: context
                                                              .labelSmall
                                                              ?.copyWith(
                                                            color: order.status
                                                                .toString()
                                                                .getOrderPrimaryStatusColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // ── Payment Pending Seal ──
                                            if (!isPaid)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        bottom: 16),
                                                child: Center(
                                                  child: Transform.rotate(
                                                    angle: -0.15,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 20,
                                                              vertical: 10),
                                                      decoration:
                                                          BoxDecoration(
                                                        border: Border.all(
                                                          color: context.color
                                                              .primaryPendingColor,
                                                          width: 3,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        "PAYMENT PENDING",
                                                        style: context
                                                            .titleMedium?.bold
                                                            .copyWith(
                                                          color: context.color
                                                              .primaryPendingColor,
                                                          letterSpacing: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            12.toHeight,
                                          ],
                                        ),
                                      ),

                                      24.toHeight,
                                    ],
                                  ),
                                ),
                              ),

                              // ── Bottom Buttons ──
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: context.color.accentContrastColor,
                                  border: Border(
                                    top: BorderSide(
                                        color:
                                            context.color.primaryBorderColor),
                                  ),
                                ),
                                child: SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Download Invoice
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            downloadInvoicePdf(
                                              context,
                                              orderId: order.id,
                                              invoiceNumber:
                                                  order.invoiceNumber,
                                            );
                                          },
                                          icon: SvgAssets.download
                                              .toSVGSized(18,
                                                  color: primaryColor),
                                          label: Text(
                                            LocalKeys.downloadInvoice,
                                            style:
                                                context.titleSmall?.bold6
                                                    .copyWith(
                                              color: primaryColor,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: primaryColor),
                                            padding: const EdgeInsets
                                                .symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      12.toHeight,
                                      // Continue to Home
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            context.toUntilPage(
                                                const LandingView());
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            padding: const EdgeInsets
                                                .symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            "Continue to Home",
                                            style: context.titleSmall?.bold
                                                .copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
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
                          color: context.color.accentContrastColor
                              .withOpacity(.7),
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

  Widget _buildTearLine(BuildContext context) {
    return Row(
      children: List.generate(
        150,
        (index) => Expanded(
          child: Container(
            height: 1,
            color: index.isEven
                ? context.color.primaryBorderColor
                : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomNetworkImage(
            height: 52,
            width: 52,
            radius: 8,
            fit: BoxFit.cover,
            imageUrl: item.image,
          ),
          12.toWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemTitle ?? "---",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.titleSmall?.bold,
                ),
                if (item.carName != null) ...[
                  2.toHeight,
                  Row(
                    children: [
                      Icon(Icons.directions_car_filled_rounded,
                          size: 12, color: context.color.tertiaryContrastColo),
                      4.toWidth,
                      Expanded(
                        child: Text(
                          "${item.carName}${item.variantName != null ? ' (${item.variantName})' : ''}",
                          style: context.bodySmall?.copyWith(
                            fontSize: 11,
                            color: context.color.tertiaryContrastColo,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                2.toHeight,
                Text(
                  "Qty: ${item.qty}",
                  style: context.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            (item.price * item.qty).cur,
            style: context.titleSmall?.bold.price.copyWith(
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          8.toWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.bodySmall?.bold5.copyWith(fontSize: 11),
                ),
                2.toHeight,
                Text(
                  value,
                  style: context.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
