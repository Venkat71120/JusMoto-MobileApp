import 'package:car_service/helper/extension/context_extension.dart';
import 'package:flutter/material.dart';

class WarningWidget extends StatelessWidget {
  final text;
  const WarningWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: context.color.primaryPendingColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.color.primaryPendingColor)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Icon(
                Icons.warning_amber_rounded,
                color: context.color.primaryContrastColor,
                size: 40,
              )),
          const Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 16,
            child: Text(
              text,
              style: context.titleSmall
                  ?.copyWith(color: context.color.primaryContrastColor),
            ),
          ),
        ],
      ),
    );
  }
}
