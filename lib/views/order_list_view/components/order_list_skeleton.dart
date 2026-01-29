import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

class OrderListSkeleton extends StatelessWidget {
  const OrderListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemBuilder: (context, index) {
              return SquircleContainer(
                  padding: const EdgeInsets.all(16),
                  radius: 10,
                  color: context.color.accentContrastColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextSkeleton(
                            height: 12,
                            width: 30,
                          ),
                          TextSkeleton(
                            height: 12,
                            width: 44,
                          )
                        ],
                      ),
                      8.toHeight,
                      TextSkeleton(
                        height: 16,
                        width: context.width * .5,
                      ),
                      10.toHeight,
                      const Wrap(
                        spacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextSkeleton(
                            height: 14,
                            width: 30,
                          ),
                          TextSkeleton(
                            height: 12,
                            width: 56,
                          )
                        ],
                      )
                    ],
                  ));
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: 10)
        .shim;
  }
}
