import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/home_models/services_list_model.dart';
import 'package:flutter/material.dart';

import '../../helper/db_helper.dart';

class CartService with ChangeNotifier {
  final Map _cartItem = {};

  Map get cartList {
    final tempList = jsonEncode(_cartItem);
    return jsonDecode(tempList);
  }

  num get subTotal {
    num amount = 0;

    cartList.values.toList().forEach((item) {
      final service = ServiceModel.fromJson(item["service"]);
      final price = ((service.serviceCar?.discountPrice ?? 0) > 0
              ? service.serviceCar?.discountPrice
              : service.serviceCar?.price)
          .toString()
          .tryToParse;
      amount += price * item["quantity"].toString().tryToParse;
    });

    return amount;
  }

  num get totalQuantity {
    num totalQ = 0;

    cartList.values.toList().forEach((item) {
      totalQ += item["quantity"].toString().tryToParse;
    });

    return totalQ;
  }

  num get taxTotal {
    num amount = 0;

    cartList.values.toList().forEach((item) {
      amount += item["tax"].toString().tryToParse;
    });

    return amount;
  }

  get servicesForOrder {
    final services = [];
    cartList.values.toList().forEach((item) {
      try {
        services.add({
          "id": item["service"]?["id"],
          "qty": item["quantity"].toString().tryToParse,
        });
      } catch (e) {
        debugPrint(item.toString());
      }
    });
    return services;
  }

  get addonsForOrder {
    final addons = [];
    final serviceAddons = [];
    cartList.values.toList().forEach((item) {
      serviceAddons.add(item["addons"]);
    });
    for (var add in serviceAddons) {
      try {
        add.values.toList().forEach((a) {
          addons.add({
            "addon_service_id": a["addon_service_id"],
            "service_id": a["service_id"],
            "quantity": a["quantity"]
          });
        });
      } catch (e) {}
    }
    return addons;
  }

  num get totalTax {
    num amount = 0;

    cartList.values.toList().forEach((item) {
      amount += item["tax"].toString().tryToParse;
    });

    return amount;
  }

  List<ServiceModel> get jobs => List<ServiceModel>.from(
      cartList.values.toList().map((x) => ServiceModel.fromJson(x)));

  addToCart(
    String id,
    service,
  ) async {
    final cartId = id;
    final item = {
      'serviceId': id,
      "service": jsonEncode(service),
      "quantity": 1.toString(),
    };
    debugPrint(item.toString());
    await DbHelper.insert('cart', item);
    final cartI = {
      'serviceId': id,
      "service": service,
      "quantity": 1,
    };
    _cartItem.putIfAbsent(cartId, () => cartI);
    LocalKeys.addedToCartSuccessfully.showToast();
    notifyListeners();
  }

  updateToCart(
    String id,
    service,
    quantity,
  ) async {
    final item = {
      'serviceId': id.toString(),
      "service": jsonEncode(service),
      "quantity": quantity.toString(),
    };
    await DbHelper.updatedb('cart', id.toString(), item);
    final cartI = {
      'serviceId': id.toString(),
      "service": service,
      "quantity": quantity,
    };
    _cartItem.update(id, (_) => cartI);
    notifyListeners();
  }

  deleteFromCart(String id) async {
    await DbHelper.deleteDbSI('cart', id);
    _cartItem.remove(id);
    LocalKeys.itemRemovedSuccessfully.showToast();
    notifyListeners();
  }

  fetchCarts() async {
    final dbData = await DbHelper.fetchDb('cart');

    if (dbData.isEmpty) {
      return;
    }
    for (var element in dbData) {
      try {
        final data = {
          'serviceId': element["serviceId"].toString(),
          "service": jsonDecode(element["service"]),
          "quantity": element["quantity"].toString().tryToParse,
        };
        _cartItem.putIfAbsent(element['serviceId'], () => data);
      } catch (e) {}
    }

    notifyListeners();
  }

  void clearCart() async {
    final cartLength = cartList.length - 1;

    for (var i = cartLength; i >= 0; i--) {
      final id = cartList.keys.toList()[i];
      await DbHelper.deleteDbSI('cart', id);
      _cartItem.remove(id);
    }
    notifyListeners();
  }
}


/*Cart Item Dummy

{
  "service":serviceDetails,
  "address":address,
  "addons":addons,
  "date":date,
  "schedule":schedule,
  "schedule":staff,
  "note":note,
  "tax": tax,
  "total":total,

}

 */