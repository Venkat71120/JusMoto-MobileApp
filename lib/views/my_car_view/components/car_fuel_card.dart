import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';

class CarFuelCard extends StatelessWidget {
  final dynamic id;
  final String name;
  final String icon;
  final bool isSelected;
  const CarFuelCard(
      {super.key,
      this.id,
      required this.name,
      required this.icon,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
        radius: 8,
        borderColor:
            isSelected ? primaryColor : context.color.primaryBorderColor,
        color: isSelected
            ? primaryColor.withOpacity(0.05)
            : context.color.accentContrastColor,
        padding: 8.paddingAll,
        height: (context.width - 64) / 3.6,
        width: (context.width - 64) / 3,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomNetworkImage(
                height: 30,
                width: 30,
                imageUrl: icon,
                carPlaceholder: true,
              ),
              8.toHeight,
              Text(
                name,
                textAlign: TextAlign.center,
                style: context.titleSmall
                    ?.copyWith(
                        color: isSelected
                            ? primaryColor
                            : context.color.primaryContrastColor)
                    .bold,
              )
            ],
          ),
        ));
  }
}
