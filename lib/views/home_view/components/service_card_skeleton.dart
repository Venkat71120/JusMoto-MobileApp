import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';

import '../../../utils/components/custom_squircle_widget.dart';
import '../../../utils/components/text_skeleton.dart';

class ServiceCardSkeleton extends StatelessWidget {
  final double? width;
  const ServiceCardSkeleton({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
      width: width ?? 188,
      padding: const EdgeInsets.all(8),
      radius: 12,
      color: context.color.accentContrastColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SquircleContainer(
              width: 172,
              height: 128,
              radius: 8,
              color: context.color.mutedContrastColor,
              child: const SizedBox()),
          12.toHeight,
          const TextSkeleton(
            height: 14,
            width: 156,
          ),
          4.toHeight,
          const TextSkeleton(
            height: 14,
            width: 100,
          ),
          12.toHeight,
          Row(
            children: [
              const TextSkeleton(
                height: 12,
                width: 26,
              ),
              6.toWidth,
              const TextSkeleton(
                height: 12,
                width: 36,
              ),
            ],
          ),
          12.toHeight,
          const TextSkeleton(
            height: 14,
            width: 76,
          ),
        ],
      ),
    );
  }
}
