import 'package:flutter/material.dart';

class OfferDetailsViewModel {
  final ValueNotifier<num> taxNotifier = ValueNotifier(0);
  num get tax => taxNotifier.value;
  String _taxType = "percentage";
  String get taxType => _taxType;
  bool taxCalculated = false;

  setTax(num amount, type) {
    taxNotifier.value = amount;
    _taxType = type ?? "percentage";
    taxCalculated = true;
  }

  num getCalculatedTax(budget) {
    if (taxType == "fixed") {
      return tax;
    }
    num ct = (tax / 100) * budget;
    return ct;
  }

  OfferDetailsViewModel._init();
  static OfferDetailsViewModel? _instance;
  static OfferDetailsViewModel get instance {
    _instance ??= OfferDetailsViewModel._init();
    return _instance!;
  }

  OfferDetailsViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }
}
