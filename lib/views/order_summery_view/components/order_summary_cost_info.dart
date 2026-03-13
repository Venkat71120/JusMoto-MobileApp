import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/booking_services/place_order_service.dart';
import 'package:car_service/utils/components/info_tile.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '../../../helper/app_urls.dart';
import '../../../helper/svg_assets.dart';
import '../../../utils/components/custom_squircle_widget.dart';

class OrderSummaryCostInfo extends StatelessWidget {
  final PlaceOrderService po;
  const OrderSummaryCostInfo({super.key, required this.po});

  @override
  Widget build(BuildContext context) {
    if (po.orderResponseModel.orderDetails == null) {
      return const SizedBox();
    }
    final orderDetails = po.orderResponseModel.orderDetails!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          SquircleContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: context.color.accentContrastColor,
            radius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoTile(
                    title: LocalKeys.subtotal,
                    value: orderDetails.subTotal.cur),
                12.toHeight,
                InfoTile(title: LocalKeys.vat, value: orderDetails.tax.cur),
                12.toHeight,
                InfoTile(
                    title: LocalKeys.deliveryCharge,
                    value: orderDetails.deliveryCharge.cur),
                12.toHeight,
                 InfoTile(
                     title: LocalKeys.discount,
                     value: "- ${orderDetails.couponAmount.cur}",
                     valueColor: orderDetails.couponAmount > 0
                         ? context.color.primarySuccessColor
                         : null,
                 ),
                Divider(
                  color: context.color.primaryBorderColor,
                  height: 32,
                ),
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
            padding: const EdgeInsets.all(12),
            color: context.color.accentContrastColor,
            radius: 12,
            child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoTile(
                  title: LocalKeys.paymentGateway,
                  value: orderDetails.paymentGateway
                          ?.replaceAll("_", " ")
                          .capitalize ??
                      "---",
                ),
                if (!["4", "5"].contains(orderDetails.status.toString()))
                  InfoTile(
                    title: LocalKeys.paymentStatus,
                    value: orderDetails.paymentStatus.toString().getPaymentStatus,
                  ),
                InfoTile(
                  title: LocalKeys.orderStatus,
                  value: orderDetails.status.toString().getOrderStatus,
                ),
                if (["complete", "1"].contains(orderDetails.paymentStatus))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = "${AppUrls.invoiceUrl}/${orderDetails.id}";
                        final Uri launchUri = Uri(
                          scheme: 'https',
                          path: url.replaceAll("https://", ""),
                        );
                        await urlLauncher.launchUrl(launchUri,
                            mode: urlLauncher.LaunchMode.externalApplication);
                      },
                      label: Text(LocalKeys.downloadInvoice),
                      icon: SvgAssets.download.toSVGSized(24,
                          color: context.color.accentContrastColor),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
