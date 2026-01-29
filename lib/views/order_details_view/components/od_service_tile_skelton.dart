import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

class OdServiceTileSkelton extends StatelessWidget {
  const OdServiceTileSkelton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: context.color.accentContrastColor,
      child: Row(
        children: [
          SquircleContainer(
            height: 72,
            width: 72,
            radius: 10,
            color: color.mutedContrastColor,
            child: const SizedBox(),
          ),
          12.toWidth,
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextSkeleton(
                  height: 14,
                  width: 88,
                ),
                const SizedBox(height: 10),
                TextSkeleton(
                  height: 16,
                  width: context.width * .8,
                ),
                const SizedBox(height: 10),
                const TextSkeleton(
                  height: 14,
                  width: 66,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
