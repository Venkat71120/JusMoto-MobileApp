import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/info_tile.dart';
import 'package:car_service/view_models/refund_list_view_model/refund_list_view_model.dart';
import 'package:flutter/material.dart';

import '../../models/order_models/refund_details_model.dart';
import '../payment_info_update_view.dart';

class RefundDetailsPaymentInfo extends StatelessWidget {
  final RefundDetails refundDetails;
  const RefundDetailsPaymentInfo({super.key, required this.refundDetails});

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
          ...(refundDetails.gatewayFields?.keys
                  .map(
                    (e) => InfoTile(
                        title: e.toString().replaceAll("_", " ").capitalize,
                        value: refundDetails.gatewayFields![e].toString()),
                  )
                  .toList() ??
              []),
          if ((refundDetails.gatewayFields ?? {}).isEmpty)
            Text(
              LocalKeys.noPaymentInfoFound,
              style: context.titleSmall,
            ),
          if (refundDetails.status == "0")
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  RefundListViewModel.instance.selectedGateway.value = null;
                  context.toPage(PaymentInfoUpdateView(
                    paymentGatewayId: refundDetails.gatewayId,
                  ));
                },
                child: Text(LocalKeys.updatePaymentInfo),
              ),
            )
        ],
      ),
    );
  }
}
