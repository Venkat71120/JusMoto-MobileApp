import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

class ServiceTileSkeleton extends StatelessWidget {
  const ServiceTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SquircleContainer(
              height: 64,
              width: 64,
              radius: 10,
              color: context.color.mutedContrastColor,
              child: const SizedBox()),
          const SizedBox(
            width: 16,
          ),
          Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSkeleton(
                    height: 14,
                    width: context.width * .6,
                  ),
                  4.toHeight,
                  const Wrap(
                    spacing: 6,
                    children: [
                      TextSkeleton(
                        height: 12,
                        width: 24,
                      ),
                      TextSkeleton(
                        height: 21,
                        width: 36,
                      ),
                    ],
                  ),
                  8.toHeight,
                  const TextSkeleton(
                    height: 14,
                    width: 60,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
