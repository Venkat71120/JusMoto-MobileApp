import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';

import '/helper/extension/string_extension.dart';
import '../../helper/svg_assets.dart';
import 'field_label.dart';

class PassFieldWithLabel extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isRequired;
  final initialValue;
  final onChanged;
  final onFieldSubmitted;
  final validator;
  final keyboardType;
  final textInputAction;
  final String? svgPrefix;
  final controller;
  final valueListenable;
  final Iterable<String>? autofillHints;
  const PassFieldWithLabel({
    super.key,
    required this.label,
    required this.hintText,
    this.initialValue,
    this.isRequired = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.svgPrefix,
    this.controller,
    this.valueListenable,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, isRequired: isRequired),
        ValueListenableBuilder(
          valueListenable: valueListenable,
          builder: (context, value, child) => TextFormField(
            keyboardType: keyboardType,
            textInputAction: textInputAction ?? TextInputAction.next,
            controller: controller,
            obscureText: value == true,
            autofillHints: autofillHints,
            decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: svgPrefix != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: svgPrefix!.toSVG,
                      )
                    : null,
                suffixIcon: GestureDetector(
                  onTap: () => valueListenable.value = !(value == true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: (value == true)
                        ? SvgAssets.invisible.toSVGSized(24,
                            color: context.color.tertiaryContrastColo)
                        : SvgAssets.visible.toSVGSized(24,
                            color: context.color.tertiaryContrastColo),
                  ),
                )),
            onChanged: onChanged,
            validator: validator ??
                (value) {
                  return value!.validPass;
                },
            onFieldSubmitted: onFieldSubmitted,
          ),
        ),
        16.toHeight,
      ],
    );
  }
}
