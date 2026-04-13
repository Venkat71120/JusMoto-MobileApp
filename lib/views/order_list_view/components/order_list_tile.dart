import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
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
    final statusStr = (order.status ?? 0).toString();
    final itemCount = order.items.length;

    return GestureDetector(
      onTap: () {
        context.toPage(OrderDetailsView(
          orderId: order.id,
        ));
      },
      child: SquircleContainer(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        radius: 12,
        borderColor: context.color.primaryBorderColor,
        color: context.color.accentContrastColor,
        child: Column(
          children: [
            // Top section: image + details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomNetworkImage(
                      imageUrl: order.firstServiceImage,
                      height: 80,
                      width: 80,
                      radius: 8,
                      fit: BoxFit.cover,
                    ),
                  ),
                  12.toWidth,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service title + status badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.firstServiceTitle ?? "Service",
                                    style: context.titleSmall?.bold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (itemCount > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        "+${itemCount - 1} more service${itemCount > 2 ? 's' : ''}",
                                        style: context.bodySmall?.copyWith(
                                          color: context
                                              .color.secondaryContrastColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            6.toWidth,
                            SquircleContainer(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              color: statusStr.getOrderMutedStatusColor,
                              radius: 6,
                              child: Text(
                                statusStr.getOrderStatus,
                                style: context.labelSmall?.copyWith(
                                  color: statusStr.getOrderPrimaryStatusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        8.toHeight,
                        // Placed on (Creation time)
                        Row(
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 12,
                              color: context.color.tertiaryContrastColo,
                            ),
                            4.toWidth,
                            Text(
                              order.createdAt == null
                                  ? ""
                                  : "Ordered: ${DateFormat("dd MMM, hh:mm a").format(order.createdAt!)}",
                              style: context.bodySmall?.copyWith(
                                fontSize: 10,
                                color: context.color.tertiaryContrastColo,
                              ),
                            ),
                          ],
                        ),
                        8.toHeight,
                        // Price + payment status
                        Row(
                          children: [
                            Text(order.total.cur,
                                style: context.titleMedium?.bold
                                    .price.copyWith(color: primaryColor)),
                            8.toWidth,
                            if (!["4", "5"].contains(statusStr))
                              OrderPaymentStatusChip(
                                  status:
                                      (order.paymentStatus ?? 0).toString(),
                                  isCOD: ["cod", "cash_on_delivery"]
                                      .contains(order.paymentGateway)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: context.color.primaryBorderColor,
            ),
            // Bottom section: schedule, date, chevron
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SvgAssets.calendar.toSVGSized(14,
                      color: context.color.secondaryContrastColor),
                  4.toWidth,
                  Text(
                    order.date == null
                        ? "---"
                        : DateFormat("dd MMM yyyy")
                            .format(order.date ?? DateTime.now()),
                    style: context.bodySmall?.copyWith(
                        color: context.color.secondaryContrastColor),
                  ),
                  16.toWidth,
                  SvgAssets.clock.toSVGSized(14,
                      color: context.color.secondaryContrastColor),
                  4.toWidth,
                  Expanded(
                    child: Text(
                      order.schedule?.capitalize ?? "---",
                      style: context.bodySmall?.copyWith(
                          color: context.color.secondaryContrastColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SvgAssets.chevron.toSVGSized(16,
                      color: context.color.secondaryContrastColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}