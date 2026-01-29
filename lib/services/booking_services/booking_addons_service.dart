import 'dart:convert';

import 'package:flutter/material.dart';

class BookingAddonsService with ChangeNotifier {
  final Map<String, Map> _addons = {};
  Map get addons {
    final tepAddons = jsonEncode(_addons);
    return jsonDecode(tepAddons);
  }

  num quantity(addonId) {
    final addonKey = addonId.toString();
    if (!_addons.containsKey(addonKey)) return 0;
    return _addons[addonKey]?["quantity"] ?? 0;
  }

  increaseAddonQ(addonId, title, price, serviceId) {
    final addonKey = addonId.toString();
    if (!_addons.containsKey(addonKey)) {
      _addons.addAll({
        addonKey: {
          "addon_service_id": addonKey,
          "service_id": serviceId,
          "title": title,
          "price": price,
          "quantity": 1
        }
      });
      notifyListeners();
      return;
    }
    num newQ = (_addons[addonKey]?["quantity"] ?? 0) + 1;
    _addons.update(
        addonKey,
        (_) => {
              "addon_service_id": addonKey,
              "service_id": serviceId,
              "title": title,
              "price": price,
              "quantity": newQ
            });
    notifyListeners();
  }

  decreaseAddonQ(addonId, title, price, serviceId) {
    final addonKey = addonId.toString();
    if (!_addons.containsKey(addonKey)) {
      return;
    }
    num newQ = (_addons[addonKey]?["quantity"] ?? 0) - 1;

    if (newQ <= 0) {
      _addons.remove(addonKey);
      notifyListeners();
      return;
    }
    _addons.update(
        addonKey,
        (_) => {
              "addon_service_id": addonKey,
              "service_id": serviceId,
              "title": title,
              "price": price,
              "quantity": newQ
            });
    notifyListeners();
  }

  void reset() {
    _addons.clear();
  }
}
