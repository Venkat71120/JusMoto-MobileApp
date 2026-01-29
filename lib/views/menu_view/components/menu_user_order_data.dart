import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';

class MenuUserOrderData extends StatelessWidget {
  const MenuUserOrderData({super.key});

  @override
  Widget build(BuildContext context) {
    const String value = "43";
    final String label = LocalKeys.pendingOrders;
    return Builder(builder: (context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: context.color.cardFillColor,
        child: Row(
          children: [
            OrderDataBlock(value: "43", label: LocalKeys.pendingOrders),
            Container(
              width: 2,
              height: 36,
              margin: 18.paddingH,
              color: context.color.primaryBorderColor,
            ),
            OrderDataBlock(value: "43", label: LocalKeys.completedOrders),
            Container(
              width: 2,
              height: 36,
              margin: 18.paddingH,
              color: context.color.primaryBorderColor,
            ),
            OrderDataBlock(value: "43", label: LocalKeys.totalOrders),
          ],
        ),
      );
    });
  }
}

class OrderDataBlock extends StatelessWidget {
  const OrderDataBlock({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.titleLarge?.bold,
          ),
          Text(
            label,
            style: context.bodySmall?.copyWith(
              color: context.color.secondaryContrastColor,
            ),
          ),
        ],
      ),
    );
  }
}
