import 'package:flutter/material.dart';

class ColorModel {
  final Color backgroundColor;
  final Color primaryContrastColor;
  final Color secondaryContrastColor;
  final Color tertiaryContrastColo;
  final Color accentContrastColor;
  final Color mutedContrastColor;
  final Color primarySuccessColor;
  final Color primaryWarningColor;
  final Color primaryPendingColor;
  Color get mutedPendingColor => primaryPendingColor.withOpacity(.1);
  Color get mutedWarningColor => primaryWarningColor.withOpacity(.1);
  Color get mutedSuccessColor => primarySuccessColor.withOpacity(.1);
  final Color primaryBorderColor;
  final Color cardFillColor;
  final Color inputFillColor;

  ColorModel({
    required this.backgroundColor,
    required this.primaryContrastColor,
    required this.secondaryContrastColor,
    required this.tertiaryContrastColo,
    required this.accentContrastColor,
    required this.mutedContrastColor,
    required this.primarySuccessColor,
    required this.primaryWarningColor,
    required this.primaryPendingColor,
    required this.primaryBorderColor,
    required this.cardFillColor,
    required this.inputFillColor,
  });
}
