import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/car_models/brand_list_model.dart';

class BrandListService with ChangeNotifier {
  BrandListModel? _myBrandsModel;
  BrandListModel get myBrandsModel =>
      _myBrandsModel ?? BrandListModel(allBrands: []);
  var token = "";

  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool get shouldAutoFetch => _myBrandsModel == null || token.isInvalid;

  fetchBrandList() async {
    token = getToken;

    final url = AppUrls.myBrandsListUrl;
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.brandList, headers: commonAuthHeader);

    if (responseData != null) {
      _myBrandsModel = BrandListModel.fromJson(responseData);
      nextPage = _myBrandsModel?.pagination?.nextPageUrl;
    } else {}
    _myBrandsModel ??= BrandListModel(allBrands: []);
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
      final tempData = BrandListModel.fromJson(responseData);
      for (var element in (tempData.allBrands ?? [])) {
        _myBrandsModel?.allBrands?.add(element);
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
    _myBrandsModel = null;
    token = "";
    nextPage = null;
    notifyListeners();
  }
}
