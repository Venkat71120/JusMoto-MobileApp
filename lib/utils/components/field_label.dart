import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  const FieldLabel({super.key, required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
            text: label,
            style: context.titleMedium!.copyWith(fontWeight: FontWeight.w600),
            children: [
              if (isRequired)
                TextSpan(
                  text: " *",
                  style: context.titleMedium
                      ?.copyWith(color: context.color.primaryWarningColor),
                )
            ]),
      ),
    );
  }
}
