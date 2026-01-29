import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScrollPreloader extends StatelessWidget {
  final bool whiteColor;
  final double? width;
  final bool loading;
  final String? text;
  final IconData? iconData;
  const ScrollPreloader({
    super.key,
    this.whiteColor = false,
    this.width,
    required this.loading,
    this.text,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    switch (loading) {
      case false:
        return Column(
          children: [
            Icon(
              iconData ?? Icons.arrow_circle_up_rounded,
              color: context.color.secondaryContrastColor,
            ),
            Text(
              text ?? LocalKeys.pullUp,
              style: context.titleSmall?.copyWith(
                color: context.color.secondaryContrastColor,
              ),
            ),
            8.toHeight,
          ],
        );
      default:
        return Container(
            width: width,
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: whiteColor ? null : 36,
            alignment: Alignment.center,
            child: LottieBuilder.asset(
                'assets/animations/${whiteColor ? 'preloader_white' : 'preloader'}.json'));
    }
  }
}
