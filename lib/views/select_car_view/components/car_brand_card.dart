import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';

class CarBrandCard extends StatelessWidget {
  final dynamic id;
  final String name;
  final String imageUrl;
  final bool isSelected;
  const CarBrandCard({
    super.key,
    this.id,
    required this.name,
    required this.imageUrl,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
      height: (context.width - 88) / 5,
      width: (context.width - 88) / 5,
      radius: 8,
      padding: 12.paddingAll,
      borderColor: isSelected ? primaryColor : context.color.primaryBorderColor,
      color: isSelected ? mutedPrimaryColor : context.color.backgroundColor,
      child: CustomNetworkImage(
        imageUrl: imageUrl,
      ),
    );
  }
}
