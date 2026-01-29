import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

extension PaddingExtension on num {
  EdgeInsetsGeometry get paddingAll => EdgeInsets.all(toDouble());

  EdgeInsetsGeometry get paddingH =>
      EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsetsGeometry get paddingV => EdgeInsets.symmetric(vertical: toDouble());
}

extension CurrencyExtension on num {
  String get cur {
    return toStringAsFixed(2).cur;
  }
}

extension RadiusExtension on num {
  BorderRadiusGeometry get circular => BorderRadius.circular(toDouble());
}

extension SizedBoxExtension on int {
  Widget get toHeight {
    switch (this) {
      case 0:
        return const SizedBox(height: 0);
      case 2:
        return const SizedBox(height: 2);
      case 4:
        return const SizedBox(height: 4);
      case 6:
        return const SizedBox(height: 6);
      case 8:
        return const SizedBox(height: 8);
      case 10:
        return const SizedBox(height: 10);
      case 12:
        return const SizedBox(height: 12);
      case 14:
        return const SizedBox(height: 14);
      case 16:
        return const SizedBox(height: 16);
      case 18:
        return const SizedBox(height: 18);
      case 20:
        return const SizedBox(height: 20);
      case 22:
        return const SizedBox(height: 22);
      case 24:
        return const SizedBox(height: 24);
      case 26:
        return const SizedBox(height: 26);
      case 28:
        return const SizedBox(height: 28);
      case 30:
        return const SizedBox(height: 30);
      case 32:
        return const SizedBox(height: 32);
      default:
        return SizedBox(height: toDouble());
    }
  }

  Widget get toWidth {
    switch (this) {
      case 0:
        return const SizedBox(width: 0);
      case 2:
        return const SizedBox(width: 2);
      case 4:
        return const SizedBox(width: 4);
      case 6:
        return const SizedBox(width: 6);
      case 8:
        return const SizedBox(width: 8);
      case 10:
        return const SizedBox(width: 10);
      case 12:
        return const SizedBox(width: 12);
      case 14:
        return const SizedBox(width: 14);
      case 16:
        return const SizedBox(width: 16);
      case 18:
        return const SizedBox(width: 18);
      case 20:
        return const SizedBox(width: 20);
      case 22:
        return const SizedBox(width: 22);
      case 24:
        return const SizedBox(width: 24);
      case 26:
        return const SizedBox(width: 26);
      case 28:
        return const SizedBox(width: 28);
      case 30:
        return const SizedBox(width: 30);
      case 32:
        return const SizedBox(width: 32);
      default:
        return SizedBox(width: toDouble());
    }
  }
}
