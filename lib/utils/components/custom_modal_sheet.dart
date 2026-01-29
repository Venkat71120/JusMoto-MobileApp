import 'package:car_service/helper/extension/context_extension.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';

class CustomModalSheet extends StatelessWidget {
  final Widget child;
  final double? maxHeight;
  final bool useConstraint;
  const CustomModalSheet(
      {super.key,
      required this.child,
      this.maxHeight,
      this.useConstraint = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: context.color.accentContrastColor,
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(
              cornerRadius: 20,
              cornerSmoothing: 0.5,
            ),
            topRight: SmoothRadius(
              cornerRadius: 20,
              cornerSmoothing: 0.5,
            ),
          ),
        ),
      ),
      constraints: useConstraint
          ? BoxConstraints(
              maxHeight: (maxHeight ?? context.height / 2) +
                  (MediaQuery.of(context).viewInsets.bottom / 2))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 4,
              width: 48,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: context.color.mutedContrastColor,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
