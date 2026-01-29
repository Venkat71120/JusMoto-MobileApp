import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomPreloader extends StatelessWidget {
  final bool whiteColor;
  final double? width;
  final double? hight;
  const CustomPreloader({
    super.key,
    this.whiteColor = false,
    this.width,
    this.hight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: whiteColor ? null : hight ?? 36,
        alignment: Alignment.center,
        child: LottieBuilder.asset(
            'assets/animations/${whiteColor ? 'preloader_white' : 'preloader'}.json'));
  }
}
