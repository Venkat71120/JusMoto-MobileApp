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
      // Give more height to accommodate the text below the image
      height: ((context.width - 88) / 5) + 36,
      width: (context.width - 88) / 5,
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      borderColor: isSelected ? primaryColor : context.color.primaryBorderColor.withOpacity(0.5),
      color: isSelected ? primaryColor.withOpacity(0.15) : context.color.accentContrastColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
               padding: const EdgeInsets.all(4),
               decoration: BoxDecoration(
                 // Add a subtle container for the logo to make it pop on dark backgrounds
                 color: Colors.white.withOpacity(isSelected ? 0.9 : 0.85),
                 borderRadius: BorderRadius.circular(6),
               ),
               child: CustomNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                carPlaceholder: true,
              ),
            ),
          ),
          4.toHeight,
          Text(
            name,
            style: context.titleSmall?.copyWith(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? primaryColor : context.color.primaryContrastColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
