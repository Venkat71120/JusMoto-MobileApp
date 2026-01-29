import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/info_tile.dart';
import 'package:flutter/material.dart';

import '../../helper/local_keys.g.dart';
import '../../models/order_models/refund_details_model.dart';

class RefundDetailsBasicInfo extends StatelessWidget {
  final RefundDetails refundDetails;
  const RefundDetailsBasicInfo({super.key, required this.refundDetails});

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      color: context.color.accentContrastColor,
      radius: 12,
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoTile(title: LocalKeys.id, value: refundDetails.id.toString()),
          if (refundDetails.order?.id != null)
            InfoTile(
              title: LocalKeys.orderId,
              value: refundDetails.order!.id.toString(),
            ),
          if (refundDetails.gatewayName != null)
            InfoTile(
              title: LocalKeys.paymentGateway,
              value: refundDetails.gatewayName.toString(),
            ),
          InfoTile(
            title: LocalKeys.refundAmount,
            value: refundDetails.amount.cur,
            valueColor: primaryColor,
          ),
          InfoTile(
            title: LocalKeys.status0,
            value: refundDetails.status.getRefundStatus,
            valueColor: refundDetails.status.getRefundPrimaryStatusColor,
          ),
        ],
      ),
    );
  }
}
