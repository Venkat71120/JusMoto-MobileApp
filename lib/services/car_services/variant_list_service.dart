import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/car_models/variant_list_model.dart';
import '../../models/car_models/car_model_list_model.dart';

class VariantListService with ChangeNotifier {
  VariantListModel? _variantListModel;
  VariantListModel get variantListModel =>
      _variantListModel ?? VariantListModel(allVariants: []);
  var token = "";

  var nextPage;
  String carId = "";

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool shouldAutoFetch({cId}) {
    return _variantListModel == null ||
        token.isInvalid ||
        cId.toString() != carId;
  }

  fetchVariantList({required cId}) async {
    token = getToken;
    carId = cId.toString();

    final url = "${AppUrls.carVariantsListUrl}/$cId/variants";
    final responseData = await NetworkApiServices()
        .getApi(url, "Variant List", headers: commonAuthHeader);

    if (responseData != null) {
      _variantListModel = VariantListModel.fromJson(responseData);
      nextPage = _variantListModel?.pagination?.nextPageUrl;
    } else {}
    _variantListModel ??= VariantListModel(allVariants: []);
    notifyListeners();
  }

  fetchNextPage() async {
    token = getToken;
    if (nextPageLoading) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData = await NetworkApiServices()
        .getApi(nextPage, "Variant List", headers: commonAuthHeader);

    if (responseData != null) {
      final tempData = VariantListModel.fromJson(responseData);
      for (var element in (tempData.allVariants ?? [])) {
        _variantListModel?.allVariants?.add(element);
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
    _variantListModel = null;
    token = "";
    carId = "";
    nextPage = null;
    notifyListeners();
  }
}
