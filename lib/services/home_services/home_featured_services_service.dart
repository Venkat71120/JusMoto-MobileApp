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
    final tempData = ServiceListModel.fromJson(jsonDecode(localData ?? "{}"));
    if (tempData.allServices.isNotEmpty) {
      _homeFeaturedServicesModel = tempData;
      fetchHomeFeaturedServices();
    }
  }

  fetchHomeFeaturedServices() async {
    var url =
        "${AppUrls.homeFeaturedServicesUrl}?variant_id=${sPref?.getString("vId")}";

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
