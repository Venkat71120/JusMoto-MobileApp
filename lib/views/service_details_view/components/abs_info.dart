import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:flutter/material.dart';

class AbsInfo extends StatelessWidget {
  final title;
  final isLast;

  const AbsInfo({
    super.key,
    this.title,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              right: context.dProvider.textDirectionRight ? 0 : 16,
              left: context.dProvider.textDirectionRight ? 16 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: mutedPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: SvgAssets.star.toSVGSized(14, color: primaryColor),
              ),
              2.toHeight,
              Container(
                  width: 2,
                  color: isLast ? null : primaryColor,
                  constraints:
                      isLast ? null : const BoxConstraints(minHeight: 16),
                  child: const VerticalDivider()),
              2.toHeight,
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: RichText(
              text: TextSpan(text: "", style: context.titleMedium, children: [
            TextSpan(text: title ?? "", style: context.bodySmall)
          ])),
        )
      ],
    );
  }
}
