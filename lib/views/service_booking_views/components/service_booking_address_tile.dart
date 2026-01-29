import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../../utils/components/custom_squircle_widget.dart';

class ServiceBookingAddressTile extends StatelessWidget {
  final ValueNotifier valueListenable;
  final bool isSelected;
  final String leadingIcon;
  final String trailingIcon;
  final void Function()? onSelect;
  final void Function()? onEdit;
  final String title;
  final String adress;
  const ServiceBookingAddressTile({
    super.key,
    required this.valueListenable,
    required this.isSelected,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.onSelect,
    required this.onEdit,
    required this.title,
    required this.adress,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        return SquircleContainer(
            radius: 10,
            padding: 8.paddingAll,
            color: isSelected ? primaryColor : null,
            borderColor:
                isSelected ? primaryColor : context.color.primaryBorderColor,
            child: Row(
              children: [
                leadingIcon.toSVGSized(24,
                    color: isSelected
                        ? context.color.accentContrastColor
                        : context.color.secondaryContrastColor),
                6.toWidth,
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.titleSmall?.bold),
                        Text(adress, style: context.bodySmall),
                      ],
                    )),
                6.toWidth,
                GestureDetector(
                  onTap: onEdit,
                  child: trailingIcon.toSVGSized(24,
                      color: isSelected
                          ? context.color.accentContrastColor
                          : context.color.secondaryContrastColor),
                ),
              ],
            ));
      },
    );
  }
}
