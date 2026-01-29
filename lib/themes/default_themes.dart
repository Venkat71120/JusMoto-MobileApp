import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/helper/extension/context_extension.dart';
import './../customizations/colors.dart';
import './../models/color_model.dart';
import './../services/theme_service.dart';

class DefaultThemes {
  InputDecorationTheme? inputDecorationTheme(
          BuildContext context, ColorModel color) =>
      InputDecorationTheme(
          hintStyle: WidgetStateTextStyle.resolveWith((states) {
            return context.titleSmall!.copyWith(
              color: color.secondaryContrastColor,
            );
          }),
          fillColor: WidgetStateColor.resolveWith(
            (states) => context.color.mutedContrastColor,
          ),
          filled: true,
          errorStyle: WidgetStateTextStyle.resolveWith((states) {
            return context.titleSmall!
                .copyWith(color: color.primaryWarningColor);
          }),
          counterStyle: WidgetStateTextStyle.resolveWith((states) {
            return context.titleSmall!
                .copyWith(color: color.primaryContrastColor);
          }),
          labelStyle: WidgetStateTextStyle.resolveWith((states) {
            return context.titleSmall!
                .copyWith(color: color.primaryContrastColor);
          }),
          helperStyle: WidgetStateTextStyle.resolveWith((states) {
            return context.titleSmall!
                .copyWith(color: color.primaryContrastColor);
          }),
          errorMaxLines: 3,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 0.5),
            borderSide: const BorderSide(color: primaryColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 0.5),
            borderSide: BorderSide(color: color.mutedContrastColor, width: 1),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 0.5),
            borderSide: BorderSide(color: color.primaryBorderColor, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 0.5),
            borderSide: BorderSide(color: color.primaryWarningColor, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 0.5),
            borderSide: BorderSide(color: color.primaryWarningColor, width: 1),
          ),
          prefixIconColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return primaryColor;
            }
            if (states.contains(WidgetState.error)) {
              return color.primaryWarningColor;
            }
            return color.secondaryContrastColor;
          }));

  CheckboxThemeData? checkboxTheme(ColorModel color) => CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          width: 1,
          color: color.primaryBorderColor,
        ),
        fillColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return color.accentContrastColor;
        }),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 4,
            cornerSmoothing: 0.5,
          ),
        ),
      );
  RadioThemeData? radioThemeData(color) => RadioThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        fillColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return color.secondaryContrastColor;
        }),
        visualDensity: VisualDensity.compact,
      );

  OutlinedButtonThemeData? outlinedButtonTheme(BuildContext context, color,
          {foregroundColor}) =>
      OutlinedButtonThemeData(
          style: ButtonStyle(
        overlayColor:
            WidgetStateColor.resolveWith((states) => Colors.transparent),
        shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((states) {
          return SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 10,
              cornerSmoothing: 0.5,
            ),
          );
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return const BorderSide(
              color: primaryColor,
            );
          }
          return BorderSide(
            color: color.primaryBorderColor,
          );
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return primaryColor;
          }
          if (states.contains(WidgetState.selected)) {
            return color.accentContrastColor;
          }
          return foregroundColor ?? color.secondaryContrastColor;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        textStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.titleSmall
                ?.copyWith(color: color.secondaryContrastColor);
          }
          if (states.contains(WidgetState.pressed)) {
            return context.titleSmall
                ?.copyWith(color: color.accentContrastColor);
          }
          return context.titleSmall?.copyWith(color: color.accentContrastColor);
        }),
      ));

  ElevatedButtonThemeData? elevatedButtonTheme(BuildContext context, color) =>
      ElevatedButtonThemeData(
          style: ButtonStyle(
        elevation: WidgetStateProperty.resolveWith((states) => 0),
        overlayColor:
            WidgetStateColor.resolveWith((states) => Colors.transparent),
        shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((states) {
          return SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 10,
              cornerSmoothing: 0.5,
            ),
          );
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return color.primaryContrastColor.withOpacity(.05);
          }
          if (states.contains(WidgetState.pressed)) {
            return color.primaryContrastColor;
          }
          return color.primaryContrastColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return color.secondaryContrastColor;
          }
          if (states.contains(WidgetState.pressed)) {
            return color.accentContrastColor;
          }
          return color.accentContrastColor;
        }),
        textStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.titleSmall
                ?.copyWith(color: color.secondaryContrastColor);
          }
          if (states.contains(WidgetState.selected)) {
            return context.titleSmall
                ?.copyWith(color: color.accentContrastColor);
          }
          return context.titleSmall
              ?.copyWith(color: color.primaryContrastColor);
        }),
      ));
  TextButtonThemeData? textButtonThemeData(color, BuildContext context) =>
      TextButtonThemeData(
          style: ButtonStyle(
              elevation: WidgetStateProperty.resolveWith((states) => 0),
              overlayColor:
                  WidgetStateColor.resolveWith((states) => Colors.transparent),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                return color.primaryContrastColor.withOpacity(0.0);
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return color.secondaryContrastColor;
                }
                if (states.contains(WidgetState.pressed)) {
                  return color.primaryContrastColor;
                }
                return primaryColor;
              }),
              textStyle: WidgetStateTextStyle.resolveWith((states) {
                return context.titleSmall!.bold;
              })));

  TextTheme textTheme(BuildContext context) {
    return TextTheme(
      titleLarge: context.titleLarge,
      titleMedium: context.titleMedium,
      titleSmall: context.titleSmall,
      bodyLarge: context.bodyLarge,
      bodyMedium: context.bodyMedium,
      bodySmall: context.bodySmall,
      labelLarge: context.labelLarge,
      labelMedium: context.labelMedium,
      labelSmall: context.labelSmall,
    );
  }

  appBarTheme(BuildContext context, ThemeService ts) => AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: context.color.primaryContrastColor,
        titleTextStyle: context.titleLarge?.bold6,
        elevation: 3,
        centerTitle: true,
        surfaceTintColor: context.color.accentContrastColor,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                ts.darkTheme ? Brightness.light : Brightness.dark),
      );

  themeData(BuildContext context, ColorModel color, ThemeService ts) =>
      ThemeData(
        useMaterial3: true,
        primaryColor: primaryColor,
        textTheme: textTheme(context),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
        ),
        scaffoldBackgroundColor: color.backgroundColor,
        scrollbarTheme: scrollbarTheme(color),
        appBarTheme: DefaultThemes().appBarTheme(context, ts),
        elevatedButtonTheme: elevatedButtonTheme(context, color),
        outlinedButtonTheme: outlinedButtonTheme(context, color),
        inputDecorationTheme: inputDecorationTheme(context, color),
        checkboxTheme: checkboxTheme(color),
        textButtonTheme: textButtonThemeData(color, context),
        switchTheme: switchThemeData(color),
        popupMenuTheme: popupMenuTheme(context, color),
        radioTheme: radioThemeData(color),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: context.color.accentContrastColor,
        ),
      );
}

popupMenuTheme(BuildContext context, ColorModel color) {
  return PopupMenuThemeData(
      color: color.accentContrastColor,
      surfaceTintColor: color.accentContrastColor,
      textStyle: context.titleMedium);
}

SwitchThemeData switchThemeData(ColorModel color) => SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return primaryColor.withOpacity(.1);
        }
        return color.accentContrastColor;
      }),
      trackColor:
          WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (!states.contains(WidgetState.selected)) {
          return color.primaryBorderColor;
        }
        return primaryColor;
      }),
      trackOutlineColor:
          WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (!states.contains(WidgetState.selected)) {
          return color.primaryBorderColor;
        }
        return primaryColor;
      }),
    );

ScrollbarThemeData scrollbarTheme(color) => ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.scrolledUnder)) {
          return true;
        }
        return false;
      }),
      thickness: WidgetStateProperty.resolveWith((states) => 6),
      thumbColor: WidgetStateProperty.resolveWith((states) => primaryColor),
    );
