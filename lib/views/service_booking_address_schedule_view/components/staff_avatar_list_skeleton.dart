import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';

class StaffAvatarListSkeleton extends StatelessWidget {
  const StaffAvatarListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: List.generate(3, (i) {
        return SquircleContainer(
            color: color.mutedContrastColor,
            height: 64,
            width: 64,
            radius: 32,
            child: SizedBox());
      }),
    ).shim;
  }
}
