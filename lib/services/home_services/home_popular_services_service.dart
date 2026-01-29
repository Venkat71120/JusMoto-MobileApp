import 'dart:convert';

import 'package:car_service/helper/app_urls.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/constant_helper.dart';
import '../../models/home_models/services_list_model.dart';

class HomePopularServicesService with ChangeNotifier {
  ServiceListModel? _homePopularServicesModel;
  ServiceListModel get homePopularServicesModel =>
      _homePopularServicesModel ?? ServiceListModel(allServices: []);

  bool get shouldAutoFetch => _homePopularServicesModel?.allServices == null;

  initLocal() {
    final localData = sPref?.getString("popular_services");
    final tempData = ServiceListModel.fromJson(jsonDecode(localData ?? "{}"));
    if (tempData.allServices.isNotEmpty) {
      _homePopularServicesModel = tempData;
      fetchHomePopularServices();
    }
  }

  fetchHomePopularServices() async {
    var url =
        "${AppUrls.homePopularServicesUrl}?variant_id=${sPref?.getString("vId")}&type=0";

    final responseData = await NetworkApiServices().getApi(url, null);

    try {
      if (responseData != null) {
        final tempData = ServiceListModel.fromJson(responseData);
        _homePopularServicesModel = tempData;
        sPref?.setString("popular_services", jsonEncode(responseData));
      }
    } finally {
      _homePopularServicesModel ??= ServiceListModel(allServices: []);
      notifyListeners();
    }
  }
}
