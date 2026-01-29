import 'package:car_service/models/color_model.dart';
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFB92325);
Color get mutedPrimaryColor => primaryColor.withOpacity(.1);

//Light theme colors
final ColorModel lightColors = ColorModel(
  backgroundColor: const Color(0xFFF7F7F7),
  primaryContrastColor: const Color(0xFF0F172A),
  secondaryContrastColor: const Color(0xFF475569),
  tertiaryContrastColo: const Color(0xFF64748B),
  accentContrastColor: const Color(0xFFFFFFFF),
  mutedContrastColor: const Color(0xFFF3F3F3),
  primarySuccessColor: const Color(0xFF22C55E),
  primaryWarningColor: const Color(0xFFEF4444),
  primaryPendingColor: const Color(0xFFF97316),
  primaryBorderColor: const Color(0xFFE4E4E7),
  cardFillColor: const Color(0xFFFFFFFF),
  inputFillColor: const Color(0xFFCBD5E1),
);

//Dark theme colors
final ColorModel darkColors = ColorModel(
  backgroundColor: const Color(0xFF0D0F11),
  primaryContrastColor: const Color(0xFFFFFFFF),
  secondaryContrastColor: const Color(0xFFE3E3E3),
  tertiaryContrastColo: const Color(0xFF75777B),
  accentContrastColor: const Color(0xFF191D23),
  mutedContrastColor: const Color(0xFF35383D),
  primarySuccessColor: const Color(0xFF22C55E),
  primaryWarningColor: const Color(0xFFEF4444),
  primaryPendingColor: const Color(0xFFF97316),
  primaryBorderColor: const Color(0xFF475569),
  cardFillColor: const Color(0xFF262036),
  inputFillColor: const Color(0xFF576776),
);
