import 'package:car_service/customizations/colors.dart';
import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';

class DotIndicator extends StatelessWidget {
  final bool isActive;
  final int dotCount;
  final color;
  final mutedColor;
  const DotIndicator(this.isActive,
      {super.key, this.dotCount = 3, this.color, this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        height: 8,
        width: isActive ? 20 : 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color ?? primaryColor),
          color: isActive
              ? color ?? primaryColor
              : mutedColor ?? context.color.accentContrastColor.withOpacity(.4),
        ),
      ),
    );
  }
}
