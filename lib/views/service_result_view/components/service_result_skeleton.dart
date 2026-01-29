import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../home_view/components/service_card_skeleton.dart';

class ServiceResultSkeleton extends StatelessWidget {
  const ServiceResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child:
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              8,
              (index) => ServiceCardSkeleton(width: (context.width - 46) / 2),
            ),
          ).shim,
    );
  }
}
