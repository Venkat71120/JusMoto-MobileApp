import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

import '../../../helper/constant_helper.dart';

class ProviderTileSkeleton extends StatelessWidget {
  final bool withPadding;
  const ProviderTileSkeleton({super.key, this.withPadding = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: withPadding
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
          : null,
      color: color.accentContrastColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.mutedContrastColor,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSkeleton(
                  height: 16,
                  width: context.width * .4,
                ),
                const SizedBox(height: 12),
                TextSkeleton(
                  height: 12,
                  width: context.width * .6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
