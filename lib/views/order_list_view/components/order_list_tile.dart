import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/models/order_models/order_list_model.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/views/order_list_view/components/order_payment_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../order_details_view/order_details_view.dart';

class OrderListTile extends StatelessWidget {
  final Order order;
  const OrderListTile({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.toPage(OrderDetailsView(
          orderId: order.id,
        ));
      },
      child: SquircleContainer(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(8),
        radius: 8,
        color: context.color.accentContrastColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${LocalKeys.id}: ",
                          style: context.bodySmall?.bold6,
                        ),
                        TextSpan(
                          text: order.id.toString(),
                          style: context.bodySmall?.bold
                              .copyWith(
                                  color: context.color.primaryContrastColor)
                              .bold,
                        ),
                      ],
                    ),
                  ),
                ),
                SquircleContainer(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: (order.status).toString().getOrderMutedStatusColor,
                    radius: 4,
                    child: Text(
                      (order.status).toString().getOrderStatus,
                      style: context.bodySmall?.copyWith(
                          color: (order.status)
                              .toString()
                              .getOrderPrimaryStatusColor),
                    ))
              ],
            ),
            4.toHeight,
            Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(order.total.cur,
                    style:
                        context.titleSmall?.bold.copyWith(color: primaryColor)),
                OrderPaymentStatusChip(
                    status: order.paymentStatus ?? "0",
                    isCOD: ["cod", "cash_on_delivery"]
                        .contains(order.paymentGateway)),
              ],
            ),
            8.toHeight,
            Wrap(
              children: [
                FittedBox(
                  child: Row(
                    children: [
                      SvgAssets.clock.toSVGSized(16, color: primaryColor),
                      4.toWidth,
                      Text(
                        order.time == null
                            ? "---"
                            : DateFormat("hh:mm a").format(
                                DateFormat("hh:mm").parse("${order.time}")),
                        style: context.bodySmall?.bold,
                      ),
                    ],
                  ),
                ),
                8.toWidth,
                FittedBox(
                  child: Row(
                    children: [
                      SvgAssets.calendar.toSVGSized(16, color: primaryColor),
                      4.toWidth,
                      Text(
                        order.date == null
                            ? "---"
                            : DateFormat("EEE, dd MMM yyyy")
                                .format(order.date ?? DateTime.now()),
                        style: context.bodySmall?.bold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
