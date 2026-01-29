import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../customizations/colors.dart';
import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';

class OrderDetailsBookingDate extends StatelessWidget {
  final DateTime date;
  const OrderDetailsBookingDate({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        children: [
          SvgAssets.calendar.toSVGSized(20, color: primaryColor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalKeys.date,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.titleSmall?.bold,
              ),
              6.toHeight,
              Text(
                DateFormat("EEEE, dd MMM yyyy").format(date),
                style: context.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
