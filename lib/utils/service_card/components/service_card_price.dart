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
                context.titleSmall
                    ?.copyWith(color: primaryColor, fontSize: 14)
                    .bold6,
          ),
          if (discountPrice > 0)
            TextSpan(
              text: price.toStringAsFixed(0).cur,
              style:
                  context.bodySmall
                      ?.copyWith(
                        color: context.color.tertiaryContrastColo,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: context.color.tertiaryContrastColo,
                      )
                      .bold5,
            ),
        ],
      ),
    );
  }
}
