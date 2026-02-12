import 'package:badges/badges.dart' as badge;
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';
import '../../../models/category_model.dart';
import '../../../utils/components/custom_network_image.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isSelected;
  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: ShapeDecoration(
        color: isSelected 
            ? primaryColor.withOpacity(0.1)
            : context.color.mutedContrastColor,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 24,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: isSelected
                ? primaryColor
                : context.color.primaryBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container
          Container(
            height: 32,
            width: 32,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected 
                  ? primaryColor.withOpacity(0.15)
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: CustomNetworkImage(
              imageUrl: category.image.toString(),
            ),
          ),
          8.toWidth,
          // Category name
          Text(
            category.name ?? "---",
            style: context.titleSmall?.copyWith(
              color: isSelected ? primaryColor : context.color.secondaryContrastColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (isSelected) ...[
            6.toWidth,
            Icon(
              Icons.check_circle,
              color: primaryColor,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }
}