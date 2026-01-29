import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';

class SquircleContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final double? radius;
  final double? height;
  final double? borderWidth;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;

  const SquircleContainer({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.radius,
    this.height,
    this.borderWidth,
    this.width,
    this.padding,
    this.margin,
    this.constraints,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      constraints: constraints,
      alignment: alignment,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: radius == null
          ? const BoxDecoration()
          : ShapeDecoration(
              color: color,
              shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: radius!,
                    cornerSmoothing: 0.5,
                  ),
                  side: borderColor == null
                      ? BorderSide.none
                      : BorderSide(
                          color: borderColor!,
                          width: borderWidth ?? 1.0,
                        )),
            ),
      child: child,
    );
  }
}
