import 'package:flutter/material.dart';

import '../../../models/order_models/order_response_model.dart';
import 'order_details_item_tile.dart';

class OrderDetailsItems extends StatelessWidget {
  final List<OrderItem>? orderItems;
  const OrderDetailsItems({super.key, required this.orderItems});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 8,
      children: orderItems?.map((orderItem) {
            return OrderDetailsItemTile(orderItem: orderItem);
          }).toList() ??
          [],
    );
  }
}
