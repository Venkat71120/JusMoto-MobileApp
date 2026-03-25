import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/car_models/car_model_list_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../main.dart';

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

    final url = "${AppUrls.myBrandsListUrl}/$bId/cars";
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.brandList, headers: commonAuthHeader);

    if (responseData != null) {
      _carModelsModel = CarModelListModel.fromJson(responseData);
      nextPage = _carModelsModel?.pagination?.nextPageUrl;
    } else {}
    _carModelsModel ??= CarModelListModel(allCarModels: []);
    
    print("Parsed model count: ${_carModelsModel?.allCarModels?.length}");
    
    preCacheImages();
    notifyListeners();
  }

  preCacheImages() {
    if (_carModelsModel?.allCarModels == null) return;
    
    for (var car in _carModelsModel!.allCarModels!) {
      if (car.image != null && car.image!.isNotEmpty) {
        precacheImage(
          CachedNetworkImageProvider(car.image!, cacheManager: customCacheManager),
          navigatorKey.currentContext!,
        );
      }
    }
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

  void reset() {
    _carModelsModel = null;
    token = "";
    brandId = "";
    nextPage = null;
    notifyListeners();
  }
}
