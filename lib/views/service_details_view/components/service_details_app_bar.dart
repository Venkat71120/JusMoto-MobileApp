import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';

import '../../../helper/svg_assets.dart';

class ServiceDetailsAppBar extends StatelessWidget {
  const ServiceDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          context.color.tertiaryContrastColo,
          context.color.accentContrastColor
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const NavigationPopIcon(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: context.color.accentContrastColor,
              child: SvgAssets.heart.toSVG,
            ),
          )
        ],
      ),
    );
  }
}
