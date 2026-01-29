import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/marquee.dart';
import 'package:flutter/material.dart';

class CarModelCard extends StatelessWidget {
  final dynamic id;
  final String name;
  final String imageUrl;
  final bool isSelected;
  const CarModelCard({
    super.key,
    this.id,
    required this.name,
    required this.imageUrl,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
      height: (context.width - 64) / 4,
      width: (context.width - 64) / 3,
      radius: 8,
      padding: 12.paddingAll,
      borderColor: isSelected ? primaryColor : context.color.primaryBorderColor,
      color: isSelected ? mutedPrimaryColor : context.color.backgroundColor,
      child: Column(
        children: [
          CustomNetworkImage(
            imageUrl: imageUrl,
            carPlaceholder: true,
            height: ((context.width - 64) / 4) - 48,
            width: ((context.width - 64) / 3) - 24,
            fit: BoxFit.contain,
          ),
          4.toHeight,
          Marquee(
            child: Text(
              name,
              style: context.bodySmall?.bold,
            ),
          )
        ],
      ),
    );
  }
}
