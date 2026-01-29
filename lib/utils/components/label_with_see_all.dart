import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LabelWithSeeAll extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final double padding;
  const LabelWithSeeAll({
    super.key,
    required this.label,
    this.onPressed,
    this.padding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FieldLabel(
            label: label,
          ),
          RichText(
            text: TextSpan(
              text: LocalKeys.seeAll,
              style: context.titleMedium?.copyWith(color: primaryColor).bold,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (onPressed != null) onPressed!();
                },
            ),
          ),
        ],
      ),
    );
  }
}
