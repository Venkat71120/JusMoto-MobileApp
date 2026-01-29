import 'dart:math';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../helper/svg_assets.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final String svg;
  final void Function()? onPress;
  final bool haveDivider;
  final Widget? trailing;
  const MenuTile(
      {super.key,
      required this.title,
      required this.svg,
      this.onPress,
      this.trailing,
      this.haveDivider = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: context.color.accentContrastColor,
            ),
            child: Row(children: [
              svg.toSVGSized(20, color: context.color.tertiaryContrastColo),
              12.toWidth,
              Expanded(
                flex: 1,
                child: Text(
                  title,
                  style: context.titleMedium?.bold6
                      .copyWith(color: context.color.primaryContrastColor),
                ),
              ),
              12.toWidth,
              if (onPress != null)
                Transform.rotate(
                  angle: context.dProvider.textDirectionRight ? pi : 0,
                  child: SvgAssets.chevron.toSVGSized(
                    20,
                    color: context.color.secondaryContrastColor,
                  ),
                ),
              if (trailing != null) trailing!
            ]),
          ),
          if (haveDivider)
            Padding(
              padding: 24.paddingH,
              child: const SizedBox().divider,
            )
        ],
      ),
    );
  }
}
