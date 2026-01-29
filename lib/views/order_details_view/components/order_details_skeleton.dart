import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/views/order_details_view/components/od_service_tile_skelton.dart';
import 'package:flutter/material.dart';

import '../../../helper/constant_helper.dart';
import '../../../utils/components/text_skeleton.dart';

class OrderDetailsSkeleton1 extends StatelessWidget {
  const OrderDetailsSkeleton1({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const OdServiceTileSkelton(),
          const SizedBox(height: 8),
          const OdServiceTileSkelton(),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: color.accentContrastColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSkeleton(
                      height: 14,
                      width: context.width * .2,
                    ),
                    TextSkeleton(
                      height: 14,
                      width: context.width * .3,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSkeleton(
                      height: 14,
                      width: context.width * .1,
                    ),
                    TextSkeleton(
                      height: 14,
                      width: context.width * .15,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSkeleton(
                      height: 14,
                      width: context.width * .3,
                    ),
                    TextSkeleton(
                      height: 14,
                      width: context.width * .2,
                    ),
                  ],
                ),
                Divider(
                  color: color.mutedContrastColor,
                  height: 36,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSkeleton(
                      height: 14,
                      width: context.width * .2,
                    ),
                    TextSkeleton(
                      height: 14,
                      width: context.width * .2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: color.accentContrastColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSkeleton(
                      height: 14,
                      width: context.width * .2,
                    ),
                    TextSkeleton(
                      height: 14,
                      width: context.width * .3,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSkeleton(
                      height: 14,
                      width: context.width * .1,
                    ),
                    TextSkeleton(
                      height: 14,
                      width: context.width * .15,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextSkeleton(
                      height: 14,
                      width: context.width * .3,
                    ),
                    TextSkeleton(
                      height: 14,
                      width: context.width * .2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ).shim,
    );
  }
}
