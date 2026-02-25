import 'dart:convert';

import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../models/home_models/services_list_model.dart';

class HomeFeaturedServicesService with ChangeNotifier {
  ServiceListModel? _homeFeaturedServicesModel;
  ServiceListModel get homeFeaturedServicesModel =>
      _homeFeaturedServicesModel ?? ServiceListModel(allServices: []);

  bool get shouldAutoFetch => _homeFeaturedServicesModel?.allServices == null;

  initLocal() {
    final localData = sPref?.getString("feature_services");
    if (localData == null) return;

    try {
      final decoded = jsonDecode(localData);
      // ✅ FIX: Reject stale cache that uses old "all_services" key format
      if (decoded is Map && decoded.containsKey("all_services")) {
        sPref?.remove("feature_services");
        fetchHomeFeaturedServices();
        return;
      }
      final tempData = ServiceListModel.fromJson(decoded);
      if (tempData.allServices.isNotEmpty) {
        _homeFeaturedServicesModel = tempData;
        fetchHomeFeaturedServices();
      }
    } catch (_) {
      sPref?.remove("feature_services");
      fetchHomeFeaturedServices();
    }
  }

  fetchHomeFeaturedServices() async {
    final params = <String, String>{'limit': '10'};

    // ✅ FIX: Only include variant_id if actually set
    final vId = sPref?.getString("vId") ?? '';
    if (vId.isNotEmpty) params['variant_id'] = vId;

    final url = Uri.parse(AppUrls.homeFeaturedServicesUrl)
        .replace(queryParameters: params)
        .toString();

    final responseData = await NetworkApiServices().getApi(url, null);

    try {
      if (responseData != null) {
        final tempData = ServiceListModel.fromJson(responseData);
        _homeFeaturedServicesModel = tempData;
        sPref?.setString("feature_services", jsonEncode(responseData));
      }
    } finally {
      _homeFeaturedServicesModel ??= ServiceListModel(allServices: []);
      notifyListeners();
    }
  }
}