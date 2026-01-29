import 'package:car_service/helper/extension/context_extension.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';

import 'custom_preloader.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final String btText;
  final bool isLoading;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.btText,
    this.isLoading = false,
    this.height = 40,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed:
            onPressed == null
                ? null
                : isLoading
                ? () {}
                : () {
                  context.unFocus;
                  onPressed!();
                },
        style: ButtonStyle(
          shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((states) {
            return SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 0.5,
              ),
            );
          }),
        ),
        child:
            isLoading
                ? SizedBox(height: height! - 8, child: const CustomPreloader())
                : FittedBox(child: Text(btText, maxLines: 1)),
      ),
    );
  }
}
