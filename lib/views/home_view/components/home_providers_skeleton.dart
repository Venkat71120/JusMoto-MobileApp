import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

class HomeProvidersSkeleton extends StatelessWidget {
  const HomeProvidersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.accentContrastColor,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        child: Wrap(
          spacing: 8,
          children: List.generate(
              5,
              (i) => SquircleContainer(
                  width: context.width * 0.373,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  radius: 10,
                  borderColor: context.color.primaryBorderColor,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: (context.width * 0.17) / 2,
                        backgroundColor: context.color.mutedContrastColor,
                      ),
                      12.toHeight,
                      const TextSkeleton(
                        height: 14,
                        width: 100,
                      ),
                      8.toHeight,
                      const TextSkeleton(
                        height: 12,
                        width: 60,
                      ),
                    ],
                  ))),
        ).shim,
      ),
    );
  }
}
