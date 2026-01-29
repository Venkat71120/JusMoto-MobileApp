import 'package:badges/badges.dart' as badge;
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';
import '../../../models/service/service_unit_model.dart';

class ServiceUnitCard extends StatelessWidget {
  final ServiceUnit unit;
  final ValueNotifier<ServiceUnit?> unitNotifier;
  const ServiceUnitCard(
      {super.key, required this.unit, required this.unitNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: unitNotifier,
        child: Text(
          unit.title,
          style: context.bodyMedium?.bold
              .copyWith(color: context.color.secondaryContrastColor),
        ),
        builder: (context, selected, child) {
          final bool isSelected = unit.id.toString() == selected?.id.toString();
          return GestureDetector(
            onTap: () {
              if (isSelected) {
                unitNotifier.value = null;
                return;
              }
              unitNotifier.value = unit;
            },
            child: badge.Badge(
              showBadge: isSelected,
              badgeStyle: const badge.BadgeStyle(badgeColor: primaryColor),
              position: badge.BadgePosition.topEnd(top: -2, end: -2),
              badgeContent: Icon(
                Icons.done_rounded,
                color: context.color.accentContrastColor,
                size: 12,
              ),
              child: SquircleContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                radius: 10,
                borderColor: isSelected
                    ? primaryColor
                    : context.color.primaryBorderColor,
                child: child!,
              ),
            ),
          );
        });
  }
}
