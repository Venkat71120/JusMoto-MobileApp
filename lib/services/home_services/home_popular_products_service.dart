import 'dart:convert';

import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../models/home_models/services_list_model.dart';

class HomePopularProductsService with ChangeNotifier {
  ServiceListModel? _homePopularProductsModel;
  ServiceListModel get homePopularProductsModel =>
      _homePopularProductsModel ?? ServiceListModel(allServices: []);

  bool get shouldAutoFetch => _homePopularProductsModel?.allServices == null;

  initLocal() {
    final localData = sPref?.getString("popular_products");
    final tempData = ServiceListModel.fromJson(jsonDecode(localData ?? "{}"));
    if (tempData.allServices.isNotEmpty) {
      _homePopularProductsModel = tempData;
      fetchHomePopularProducts();
    }
  }

  fetchHomePopularProducts() async {
    var url =
        "${AppUrls.homePopularServicesUrl}?variant_id=${sPref?.getString("vId")}&type=1";

    final responseData = await NetworkApiServices().getApi(url, null);

    try {
      if (responseData != null) {
        final tempData = ServiceListModel.fromJson(responseData);
        _homePopularProductsModel = tempData;
        sPref?.setString("popular_products", jsonEncode(responseData));
      }
    } finally {
      _homePopularProductsModel ??= ServiceListModel(allServices: []);
      notifyListeners();
    }
  }
}
