import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

class CategoryCardSkeleton extends StatelessWidget {
  const CategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SquircleContainer(
          height: 60,
          width: 66,
          radius: 8,
          color: context.color.mutedContrastColor,
          child: const SizedBox(),
        ),
        const SizedBox(height: 10),
        const TextSkeleton(
          width: 52,
          height: 15,
        ),
      ],
    );
  }
}
