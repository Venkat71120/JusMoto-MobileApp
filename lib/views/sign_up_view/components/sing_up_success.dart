import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:flutter/material.dart';

class SingUpSuccess extends StatelessWidget {
  const SingUpSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgAssets.doneFilled.toSVGSized(
          100,
          color: context.color.primarySuccessColor,
        )
      ],
    );
  }
}
