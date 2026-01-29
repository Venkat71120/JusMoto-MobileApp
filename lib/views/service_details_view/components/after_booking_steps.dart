import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/service/service_details_model.dart';
import 'package:flutter/material.dart';

import 'abs_info.dart';

class AfterBookingSteps extends StatelessWidget {
  final List<AfterBookingStep> steps;
  const AfterBookingSteps({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const SizedBox();
    }
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.color.accentContrastColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalKeys.stepsAfterBooking,
            style: context.titleSmall?.bold6,
          ),
          12.toHeight.divider,
          12.toHeight,
          ...steps.map((e) {
            bool isLast = steps.indexOf(e) == (steps.length - 1);

            return AbsInfo(
              title: e.steps,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}
