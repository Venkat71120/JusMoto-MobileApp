import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/services/order_services/order_details_service.dart';
import 'package:car_service/views/refund_list_view/refund_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../customizations/colors.dart';
import '../../../helper/local_keys.g.dart';
import '../../cancel_order_view/cancel_order_view.dart';
import '../../invoice_view/invoice_view.dart' show downloadInvoicePdf;

class OrderDetailsButtons extends StatelessWidget {
  const OrderDetailsButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDetailsService>(
      builder: (context, od, child) {
        final orderDetails = od.orderDetailsModel.orderDetails;
        if (orderDetails == null) return const SizedBox();

        final statusStr = orderDetails.status?.toString() ?? "0";
        final isPaid = ["complete", "1"]
            .contains(orderDetails.paymentStatus?.toString());
        final isCancelled = statusStr == "4";
        final canCancel = statusStr == "0";

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            border: Border(
              top: BorderSide(color: context.color.primaryBorderColor),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Download Invoice button — always visible
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      downloadInvoicePdf(
                        context,
                        orderId: orderDetails.id,
                        invoiceNumber: orderDetails.invoiceNumber,
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: Text(
                      LocalKeys.downloadInvoice,
                      style: context.titleSmall?.bold6.copyWith(
                        color: primaryColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Cancelled + paid → go to refunds
                if (isCancelled && isPaid)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.toPage(const RefundListView());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        LocalKeys.refunds,
                        style: context.titleSmall?.bold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                // Pending → cancel order
                else if (canCancel)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.toPage(const CancelOrderView());
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: context.color.primaryWarningColor,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        LocalKeys.cancelOrder,
                        style: context.titleSmall?.bold.copyWith(
                          color: context.color.primaryWarningColor,
                        ),
                      ),
                    ),
                  )
                // Everything else → back to orders
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Back to Orders",
                        style: context.titleSmall?.bold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
