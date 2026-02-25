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
    if (localData == null) return;

    try {
      final decoded = jsonDecode(localData);
      // ✅ FIX: Reject stale cache that uses old "all_services" key format
      // Old cache will have null prices and wrong field names — discard it
      if (decoded is Map && decoded.containsKey("all_services")) {
        sPref?.remove("popular_products");
        fetchHomePopularProducts();
        return;
      }
      final tempData = ServiceListModel.fromJson(decoded);
      if (tempData.allServices.isNotEmpty) {
        _homePopularProductsModel = tempData;
        fetchHomePopularProducts();
      }
    } catch (_) {
      sPref?.remove("popular_products");
      fetchHomePopularProducts();
    }
  }

  fetchHomePopularProducts() async {
    // type=1 → Products only; sort by newest
    final params = <String, String>{
      'type': '1',
      'sort_by': 'created_at',
      'sort_order': 'DESC',
      'limit': '15',
    };

    // ✅ FIX: Only include variant_id if actually set — avoids sending empty string
    final vId = sPref?.getString("vId") ?? '';
    if (vId.isNotEmpty) params['variant_id'] = vId;

    final url = Uri.parse(AppUrls.homePopularServicesUrl)
        .replace(queryParameters: params)
        .toString();

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