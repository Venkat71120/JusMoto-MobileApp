import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';

class SliderSkeleton extends StatelessWidget {
  const SliderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: context.color.accentContrastColor,
      ),
      child: SquircleContainer(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              width: context.width * 0.82,
              height: ((context.width - 24) / 307) * 150,
              radius: 12,
              color: context.color.mutedContrastColor,
              child: const SizedBox())
          .shim,
    );
  }
}
