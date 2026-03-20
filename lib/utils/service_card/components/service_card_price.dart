import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

class ServiceCardPrice extends StatelessWidget {
  final num price;
  final num discountPrice;
  const ServiceCardPrice({
    super.key,
    required this.price,
    required this.discountPrice,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: null,
        children: [
          TextSpan(
            text: "${discountPrice > 0 ? discountPrice.cur : price.cur} ",
            style:
                context.labelMedium
                    ?.copyWith(color: primaryColor, fontSize: 13)
                    .bold6.price,
          ),
          if (discountPrice > 0)
            TextSpan(
              text: price.toStringAsFixed(0).cur,
              style:
                  context.bodySmall
                      ?.copyWith(
                        color: context.color.tertiaryContrastColo,
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: context.color.tertiaryContrastColo,
                      )
                      .bold5.price,
            ),
        ],
      ),
    );
  }
}
