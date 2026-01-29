import 'package:badges/badges.dart' as badge;
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';
import '../../../models/category_model.dart';
import '../../../utils/components/custom_network_image.dart';
import '../../../utils/components/marquee.dart';

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
    return badge.Badge(
      showBadge: isSelected,
      badgeStyle: const badge.BadgeStyle(badgeColor: primaryColor),
      position: badge.BadgePosition.topEnd(top: -2, end: -2),
      badgeContent: Icon(
        Icons.done_rounded,
        color: context.color.accentContrastColor,
        size: 12,
      ),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              height: 60,
              width: 66,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: ShapeDecoration(
                color: context.color.mutedContrastColor,
                shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 8,
                      cornerSmoothing: 0.5,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? primaryColor
                          : context.color.primaryBorderColor,
                    )),
              ),
              child: CustomNetworkImage(
                imageUrl: category.image.toString(),
              ),
            ),
            8.toHeight,
            Marquee(
              directionMarguee: DirectionMarguee.TwoDirection,
              child: Text(
                category.name ?? "---",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.titleSmall,
              ),
            )
          ],
        ),
      ),
    );
  }
}
