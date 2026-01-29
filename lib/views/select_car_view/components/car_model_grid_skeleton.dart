import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';

class CarModelGridSkeleton extends StatelessWidget {
  const CarModelGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 8),
      physics: AlwaysScrollableScrollPhysics(),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          15,
          (index) {
            return SquircleContainer(
              height: (context.width - 70) / 4,
              width: (context.width - 70) / 3,
              radius: 8,
              color: context.color.mutedContrastColor,
              child: SizedBox(),
            );
          },
        ),
      ),
    ).shim;
  }
}
