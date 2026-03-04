import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';
import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../models/order_models/order_response_model.dart';

class OrderDetailsAddress extends StatelessWidget {
  // ✅ UPDATED: accepts OrderLocation instead of Address
  final OrderLocation address;
  const OrderDetailsAddress({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgAssets.mapPin.toSVGSized(20, color: primaryColor),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalKeys.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.titleSmall?.bold,
                ),
                8.toHeight,
                Text(
                  address.address ?? "---",
                  style: context.bodySmall,
                ),
                if (address.phone != null) ...[
                  4.toHeight,
                  Text(
                    address.phone!,
                    style: context.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}