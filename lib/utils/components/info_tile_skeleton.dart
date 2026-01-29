import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';

class InfoTileSkeleton extends StatelessWidget {
  const InfoTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextSkeleton(
          height: 14,
          width: 80,
        ),
        12.toWidth,
        TextSkeleton(
          height: 16,
          width: 56,
        ),
      ],
    ).shim;
  }
}
