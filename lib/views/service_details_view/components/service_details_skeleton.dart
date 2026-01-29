import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

class ServiceDetailsSkeleton extends StatelessWidget {
  const ServiceDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:
            Column(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  color: context.color.mutedContrastColor,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  width: double.infinity,
                  color: context.color.accentContrastColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Wrap(
                        spacing: 6,
                        children: [
                          TextSkeleton(height: 16, width: 26),
                          TextSkeleton(height: 16, width: 26),
                        ],
                      ),
                      8.toHeight,
                      TextSkeleton(height: 18, width: context.width * .8),
                      6.toHeight,
                      TextSkeleton(height: 18, width: context.width * .4),
                      12.toHeight,

                      TextSkeleton(
                        height: 18,
                        width: 120,
                        color: mutedPrimaryColor,
                      ),
                    ],
                  ),
                ),
                8.toHeight,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  color: context.color.accentContrastColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Wrap(
                        spacing: 12,
                        children: [
                          TextSkeleton(height: 16, width: 60),
                          TextSkeleton(height: 16, width: 40),
                          TextSkeleton(height: 16, width: 48),
                        ],
                      ),
                      16.toHeight,
                      const SizedBox().divider,
                      16.toHeight,
                      TextSkeleton(height: 14, width: context.width * .8),
                      4.toHeight,
                      TextSkeleton(height: 14, width: context.width * .7),
                      4.toHeight,
                      TextSkeleton(height: 14, width: context.width * .4),
                      16.toHeight,
                      const TextSkeleton(height: 16, width: 80),
                      16.toHeight,
                      const SizedBox().divider,
                      12.toHeight,

                      TextSkeleton(
                        height: 14,
                        width: context.width * .3,
                        color: mutedPrimaryColor,
                      ),
                      4.toHeight,
                      TextSkeleton(
                        height: 14,
                        width: context.width * .5,
                        color: mutedPrimaryColor,
                      ),
                      4.toHeight,
                      TextSkeleton(
                        height: 14,
                        width: context.width * .4,
                        color: mutedPrimaryColor,
                      ),
                      16.toHeight,
                      const TextSkeleton(height: 16, width: 80),
                      16.toHeight,
                      const SizedBox().divider,
                      12.toHeight,

                      TextSkeleton(
                        height: 14,
                        width: context.width * .3,
                        color: context.color.mutedSuccessColor,
                      ),
                      4.toHeight,
                      TextSkeleton(
                        height: 14,
                        width: context.width * .5,
                        color: context.color.mutedSuccessColor,
                      ),
                      4.toHeight,
                      TextSkeleton(
                        height: 14,
                        width: context.width * .4,
                        color: context.color.mutedSuccessColor,
                      ),
                      4.toHeight,
                      TextSkeleton(
                        height: 14,
                        width: context.width * .5,
                        color: context.color.mutedSuccessColor,
                      ),
                      4.toHeight,
                      TextSkeleton(
                        height: 14,
                        width: context.width * .4,
                        color: context.color.mutedSuccessColor,
                      ),
                    ],
                  ),
                ),
              ],
            ).shim,
      ),
    );
  }

  Widget subInfo(BuildContext context, {bool isMiddle = false}) {
    return Container(
      alignment: Alignment.center,
      padding: 6.paddingH,
      decoration: BoxDecoration(
        border:
            !isMiddle
                ? null
                : Border(
                  left: BorderSide(
                    color: context.color.primaryBorderColor,
                    width: 2,
                  ),
                  right: BorderSide(
                    color: context.color.primaryBorderColor,
                    width: 2,
                  ),
                ),
      ),
      constraints: BoxConstraints(minWidth: (context.width - 52) / 3),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [TextSkeleton(height: 16, width: 88)],
      ),
    );
  }
}
