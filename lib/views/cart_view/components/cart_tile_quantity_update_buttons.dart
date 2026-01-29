import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';

class CartTileQuantityUpdateButtons extends StatelessWidget {
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  const CartTileQuantityUpdateButtons({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: SquircleContainer(
        radius: 8,
        color: context.color.primaryContrastColor,
        padding: EdgeInsets.all(6),
        child: Row(
          children: [
            GestureDetector(
              onTap: onRemove,
              child: SquircleContainer(
                padding: 4.paddingAll,
                radius: 4,
                color: context.color.accentContrastColor.withOpacity(.1),
                child: Icon(
                  Icons.remove,
                  size: 14,
                  color: context.color.accentContrastColor,
                ),
              ),
            ),
            6.toWidth,
            Text(
              '$quantity',
              style: context.bodySmall
                  ?.copyWith(color: context.color.accentContrastColor)
                  .bold6,
            ),
            6.toWidth,
            GestureDetector(
              onTap: onAdd,
              child: SquircleContainer(
                padding: 4.paddingAll,
                radius: 4,
                color: context.color.accentContrastColor.withOpacity(.1),
                child: Icon(
                  Icons.add,
                  size: 14,
                  color: context.color.accentContrastColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
