import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/constant_helper.dart';
import '../../models/home_models/services_list_model.dart';

class ServiceByCategoryService with ChangeNotifier {
  ServiceListModel? _serviceByCategoryModel;
  ServiceListModel get serviceByCategoryModel =>
      _serviceByCategoryModel ?? ServiceListModel(allServices: []);

  String? nextPage;

  dynamic categoryId;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;
  bool isLoading = false;

  bool shouldAutoFetch(id) => id.toString() != categoryId.toString();

  fetchServices({refreshing = false, catId}) async {
    var url =
        "${AppUrls.serviceListUrl}?variant_id=${sPref?.getString("vId")}&cat_id=$catId";
    categoryId = catId;
    final responseData =
        await NetworkApiServices().getApi(url, LocalKeys.searchService);

    try {
      if (responseData != null) {
        final tempData = ServiceListModel.fromJson(responseData);
        _serviceByCategoryModel = tempData;
        nextPage = tempData.pagination?.nextPageUrl;
      } else {
        _serviceByCategoryModel ??= ServiceListModel(allServices: []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  fetchNextPage() async {
    if (nextPageLoading || nextPage == null) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData =
        await NetworkApiServices().getApi(nextPage!, LocalKeys.jobs);

    if (responseData != null) {
      final tempData = ServiceListModel.fromJson(responseData);
      for (var element in tempData.allServices) {
        _serviceByCategoryModel?.allServices.add(element);
      }
      nextPage = tempData.pagination?.nextPageUrl;
    } else {
      nexLoadingFailed = true;
      Future.delayed(const Duration(seconds: 1)).then((value) {
        nexLoadingFailed = false;
        notifyListeners();
      });
    }
    nextPageLoading = false;
    notifyListeners();
  }
}
