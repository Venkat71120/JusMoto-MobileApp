import 'package:car_service/helper/extension/context_extension.dart';
import 'package:flutter/material.dart';

class FranchiseReportsView extends StatelessWidget {
  const FranchiseReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Reports'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No reports available',
              style: context.titleMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}