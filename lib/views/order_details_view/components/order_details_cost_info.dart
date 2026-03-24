import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/order_services/order_details_service.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/info_tile.dart';
import 'package:car_service/views/order_details_view/components/pay_again_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '../../../customizations/colors.dart';
import '../../../helper/app_urls.dart';
import '../../../helper/svg_assets.dart';

class OrderDetailsCostInfo extends StatelessWidget {
  final OrderDetailsService od;
  const OrderDetailsCostInfo({super.key, required this.od});

  @override
  Widget build(BuildContext context) {
    final orderDetails = od.orderDetailsModel.orderDetails!;

    final isPaid =
        ["complete", "1"].contains(orderDetails.paymentStatus?.toString());
    final isOrderAccepted =
        ["1", "2", "3"].contains(orderDetails.status?.toString());

    return Column(
      children: [
        // ── Price Breakdown ──
        SquircleContainer(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(12),
          color: context.color.accentContrastColor,
          radius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoTile(
                title: LocalKeys.subtotal,
                value: orderDetails.subTotal.cur,
              ),
              12.toHeight,
              InfoTile(
                title: LocalKeys.discount,
                value: "- ${orderDetails.couponAmount.cur}",
                valueColor: orderDetails.couponAmount > 0
                    ? context.color.primarySuccessColor
                    : null,
              ),
              12.toHeight,
              InfoTile(title: LocalKeys.vat, value: orderDetails.tax.cur),
              12.toHeight,
              InfoTile(
                title: LocalKeys.deliveryCharge,
                value: orderDetails.deliveryCharge.cur,
              ),
              Divider(color: context.color.primaryBorderColor, height: 32),
              InfoTile(
                title: LocalKeys.total,
                value: orderDetails.total.cur,
                fontSize: 18,
              ),
            ],
          ),
        ),
        8.toHeight,

        // ── Payment & Order Status ──
        SquircleContainer(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(12),
          color: context.color.accentContrastColor,
          radius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment gateway
              InfoTile(
                title: LocalKeys.paymentGateway,
                value: orderDetails.paymentGateway
                        ?.replaceAll("_", " ")
                        .capitalize ??
                    "---",
              ),
              12.toHeight,

              // Payment status with badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      LocalKeys.paymentStatus,
                      style: context.bodySmall?.bold5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? context.color.primarySuccessColor.withOpacity(0.1)
                          : context.color.primaryPendingColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPaid ? "Paid" : "Unpaid",
                      style: context.labelSmall?.copyWith(
                        color: isPaid
                            ? context.color.primarySuccessColor
                            : context.color.primaryPendingColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              12.toHeight,

              // Order status with badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      LocalKeys.orderStatus,
                      style: context.bodySmall?.bold5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: orderDetails.status
                          .toString()
                          .getOrderMutedStatusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      orderDetails.status.toString().getOrderStatus,
                      style: context.labelSmall?.copyWith(
                        color: orderDetails.status
                            .toString()
                            .getOrderPrimaryStatusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              12.toHeight,

              // Pay Now button — only for non-COD unpaid orders
              if (!isPaid &&
                  !([
                    "cash_on_delivery",
                    "manual_payment",
                    "cod",
                  ].contains(orderDetails.paymentGateway)) &&
                  ["0", "1", "2"].contains(orderDetails.status?.toString()))
                const PayAgainButton(),

              // Download Invoice — only when paid + accepted
              if (isPaid && isOrderAccepted)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final url =
                          "${AppUrls.invoiceUrl}/${orderDetails.id}";
                      final Uri launchUri = Uri.parse(url);
                      await urlLauncher.launchUrl(
                        launchUri,
                        mode: urlLauncher.LaunchMode.externalApplication,
                      );
                    },
                    label: Text(
                      LocalKeys.downloadInvoice,
                      style: context.titleSmall?.bold6.copyWith(
                        color: primaryColor,
                      ),
                    ),
                    icon: SvgAssets.download.toSVGSized(
                      20,
                      color: primaryColor,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
