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

import '../../../helper/app_urls.dart';
import '../../../helper/svg_assets.dart';

class OrderDetailsCostInfo extends StatelessWidget {
  final OrderDetailsService od;
  const OrderDetailsCostInfo({super.key, required this.od});

  @override
  Widget build(BuildContext context) {
    final orderDetails = od.orderDetailsModel.orderDetails!;
    return Column(
      children: [
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
        SquircleContainer(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(12),
          color: context.color.accentContrastColor,
          radius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              InfoTile(
                title: LocalKeys.paymentGateway,
                value:
                    orderDetails.paymentGateway
                        ?.replaceAll("_", " ")
                        .capitalize ??
                    "---",
              ),

              InfoTile(
                title: LocalKeys.paymentStatus,
                value: orderDetails.paymentStatus.toString().getPaymentStatus,
              ),

              InfoTile(
                title: LocalKeys.orderStatus,
                value: orderDetails.status.toString().getOrderStatus,
              ),

              if (!([
                    "cash_on_delivery",
                    "manual_payment",
                    "cod",
                  ].contains(orderDetails.paymentGateway)) &&
                  [
                    "pending",
                    "0",
                  ].contains(orderDetails.paymentStatus?.toString()) &&
                  ["0", "1", "2"].contains(orderDetails.status?.toString()))
                const PayAgainButton(),
              if (["complete", "1"].contains(orderDetails.paymentStatus) &&
                  ["0", "1", "2"].contains(orderDetails.status?.toString()))
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final url = "${AppUrls.invoiceUrl}/${orderDetails.id}";
                      final Uri launchUri = Uri(
                        scheme: 'https',
                        path: url.replaceAll("https://", ""),
                      );
                      await urlLauncher.launchUrl(
                        launchUri,
                        mode: urlLauncher.LaunchMode.externalApplication,
                      );
                    },
                    label: Text(LocalKeys.downloadInvoice),
                    icon: SvgAssets.download.toSVGSized(
                      24,
                      color: context.color.secondaryContrastColor,
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
