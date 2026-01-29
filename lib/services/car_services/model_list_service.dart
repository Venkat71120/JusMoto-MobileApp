import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/car_models/car_model_list_model.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';

class ModelListService with ChangeNotifier {
  CarModelListModel? _carModelsModel;
  CarModelListModel get carModelsModel =>
      _carModelsModel ?? CarModelListModel(allCarModels: []);
  var token = "";

  var nextPage;
  String brandId = "";

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool shouldAutoFetch({bId}) {
    return _carModelsModel == null ||
        token.isInvalid ||
        bId.toString() != brandId;
  }

  fetchCarModelList({required bId}) async {
    token = getToken;
    brandId = bId.toString();

    final url = "${AppUrls.carModelsListUrl}?brand_id=$bId";
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.brandList, headers: commonAuthHeader);

    if (responseData != null) {
      _carModelsModel = CarModelListModel.fromJson(responseData);
      nextPage = _carModelsModel?.pagination?.nextPageUrl;
    } else {}
    _carModelsModel ??= CarModelListModel(allCarModels: []);
    notifyListeners();
  }

  fetchNextPage() async {
    token = getToken;
    if (nextPageLoading) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData = await NetworkApiServices()
        .getApi(nextPage, LocalKeys.brandList, headers: commonAuthHeader);

    if (responseData != null) {
      final tempData = CarModelListModel.fromJson(responseData);
      for (var element in (tempData.allCarModels ?? [])) {
        _carModelsModel?.allCarModels?.add(element);
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
