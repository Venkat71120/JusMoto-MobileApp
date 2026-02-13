import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';

class FranchiseOrdersView extends StatelessWidget {
  const FranchiseOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(LocalKeys.orders),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              LocalKeys.noOrdersFound,
              style: context.titleMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}