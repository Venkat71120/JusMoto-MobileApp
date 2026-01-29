import 'package:badges/badges.dart' as badges;
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:flutter/material.dart';

class SelectableStaffAvatar extends StatelessWidget {
  final id;
  final bool isSelected;
  final String? imageUrl;
  final String? name;
  final void Function() onSelect;
  const SelectableStaffAvatar(
      {super.key,
      this.id,
      required this.isSelected,
      this.imageUrl,
      this.name,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: badges.Badge(
          showBadge: isSelected,
          badgeContent:
              SvgAssets.doneFilled.toSVGSized(26, color: primaryColor),
          badgeStyle: badges.BadgeStyle(
            padding: EdgeInsets.all(2),
            badgeColor: Colors.white,
          ),
          child: CustomNetworkImage(
            height: 52,
            width: 52,
            radius: 26,
            fit: BoxFit.cover,
            name: name,
            imageUrl: imageUrl,
          ),
        ),
      ),
    );
  }
}
