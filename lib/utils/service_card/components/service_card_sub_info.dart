import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/marquee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../helper/svg_assets.dart';

class ServiceCardSubInfo extends StatelessWidget {
  final num avgRating;
  final num soldCount;
  const ServiceCardSubInfo({
    super.key,
    required this.avgRating,
    this.soldCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Marquee(
      animationDuration: 2000.milliseconds,
      backDuration: 2000.milliseconds,
      child: Row(
        children: [
          if (avgRating > 0) ...[
            SvgAssets.star.toSVGSized(
              16,
              color: context.color.primaryPendingColor,
            ),
            4.toWidth,
          ],
          RichText(
            text: TextSpan(
              text: null,
              style: context.bodySmall?.copyWith(
                color: context.color.tertiaryContrastColo,
              ),
              children: [
                if ((avgRating > 0))
                  TextSpan(
                    text: "${avgRating.toStringAsFixed(1)} ",
                    style: context.bodyMedium?.bold6,
                  ),
                if (soldCount > 0 && avgRating > 0) TextSpan(text: "."),
                if (soldCount > 0)
                  TextSpan(
                    text: " ${LocalKeys.sold}: ${formatNumber(soldCount)}",
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatNumber(num number) {
    if (number >= 1000 && number < 1000000) {
      return "${(number / 1000).toStringAsFixed(1)}k";
    } else if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else {
      return number.toString();
    }
  }
}
