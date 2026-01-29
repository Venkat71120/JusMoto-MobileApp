import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/dynamics/cancellation_policy_service.dart';
import 'package:car_service/services/order_services/order_details_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../utils/components/alerts.dart';

class OrderDetailsButtons extends StatelessWidget {
  const OrderDetailsButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDetailsService>(
      builder: (context, od, child) {
        final cs = CancellationPolicyService.instance;

        if ((cs.cancellationData.value["available_type"] == "certain_time" &&
                ((od.orderDetailsModel.orderDetails?.createdAt != null
                        ? DateTime.now()
                            .difference(
                              od.orderDetailsModel.orderDetails!.createdAt!,
                            )
                            .inMinutes
                        : 0) >
                    cs.cancellationData.value["time_in_min"]
                        .toString()
                        .tryToParse)) ||
            !(["0", "1"].contains(
              od.orderDetailsModel.orderDetails?.status?.toString(),
            ))) {
          return SizedBox();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            border: Border(
              top: BorderSide(color: context.color.primaryBorderColor),
            ),
          ),
          child: Wrap(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Alerts().confirmationAlert(
                      context: context,
                      title: LocalKeys.areYouSure,
                      description: cs.cancellationData.value["description"],
                      onConfirm: () async {
                        final result =
                            await Provider.of<OrderDetailsService>(
                              context,
                              listen: false,
                            ).tryCancelOrder();
                        if (result) {
                          context.pop;
                        }
                      },
                    );
                  },
                  label: Text(LocalKeys.cancelOrder),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
