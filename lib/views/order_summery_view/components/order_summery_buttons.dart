import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/services/booking_services/place_order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../invoice_view/invoice_view.dart' show downloadInvoicePdf;

class OrderSummeryButtons extends StatelessWidget {
  const OrderSummeryButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          border:
              Border(top: BorderSide(color: context.color.primaryBorderColor))),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: () {
                final order =
                    Provider.of<PlaceOrderService>(context, listen: false)
                        .orderResponseModel
                        .orderDetails;
                if (order == null) return;
                downloadInvoicePdf(
                  context,
                  orderId: order.id,
                  invoiceNumber: order.invoiceNumber,
                );
              },
              label: Text(LocalKeys.downloadInvoice),
              icon: SvgAssets.download.toSVGSized(
                24,
                color: context.color.accentContrastColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
