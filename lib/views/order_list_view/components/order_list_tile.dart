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
import '../../../utils/components/custom_network_image.dart';

class OrderListTile extends StatelessWidget {
  final Order order;
  final int index;
  const OrderListTile({
    super.key,
    required this.order,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ UPDATED: Convert int? status to String for existing string extensions
    final statusStr = (order.status ?? 0).toString();

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomNetworkImage(
              imageUrl: order.firstServiceImage,
              height: 70,
              width: 70,
              radius: 8,
            ),
            12.toWidth,
            Expanded(
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
                                text: "#${index + 1} | ${LocalKeys.id}: ",
                                style: context.bodySmall?.bold6,
                              ),
                              TextSpan(
                                text: order.id.toString(),
                                style: context.bodySmall?.bold.copyWith(
                                    color: context.color.primaryContrastColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SquircleContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          // ✅ UPDATED: Use pre-converted statusStr
                          color: statusStr.getOrderMutedStatusColor,
                          radius: 4,
                          child: Text(
                            statusStr.getOrderStatus,
                            style: context.bodySmall?.copyWith(
                                color: statusStr.getOrderPrimaryStatusColor),
                          ))
                    ],
                  ),
                  4.toHeight,
                  Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(order.total.cur,
                          style: context.titleSmall?.bold
                              .copyWith(color: primaryColor)),
                      if (!["4", "5"].contains(statusStr))
                        OrderPaymentStatusChip(
                            status: (order.paymentStatus ?? 0).toString(),
                            isCOD: ["cod", "cash_on_delivery"]
                                .contains(order.paymentGateway)),
                    ],
                  ),
                  8.toHeight,
                  Wrap(
                    children: [
                      // ✅ UPDATED: `time` is removed from API — show `schedule` instead
                      FittedBox(
                        child: Row(
                          children: [
                            SvgAssets.clock.toSVGSized(16, color: primaryColor),
                            4.toWidth,
                            Text(
                              order.schedule?.capitalize ?? "---",
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
          ],
        ),
      ),
    );
  }
}