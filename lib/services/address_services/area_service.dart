import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/local_keys.g.dart';
import '../../models/address_models/area_model.dart';

class AreaService with ChangeNotifier {
  bool areaLoading = false;
  String areaSearchText = '';
  dynamic cityId;

  List<Area> areaList = [];

  bool nextPageLoading = false;

  String? nextPage;

  bool nexLoadingFailed = false;

  setAreaSearchValue(value) {
    if (value == areaSearchText) {
      return;
    }
    areaSearchText = value;
    notifyListeners();
  }

  resetList(sId) {
    if (areaSearchText.isEmpty && areaList.isNotEmpty && sId == cityId) {
      return;
    }
    areaSearchText = '';
    areaList = [];
    cityId = sId;
    getArea();
  }

  void getArea() async {
    areaLoading = true;
    nextPage = null;
    notifyListeners();
    final url =
        "${AppUrls.areaUrl}?city_id=$cityId&search=$areaSearchText";
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.area);

    if (responseData != null) {
      final tempData = AreaModel.fromJson(responseData);
      areaList = tempData.areas;
      nextPage = tempData.pagination?.nextPageUrl;
    } else {}

    areaLoading = false;
    notifyListeners();
  }

  fetchNextPage() async {
    if (nextPageLoading || nextPage == null) return;
    nextPageLoading = true;

    final responseData =
        await NetworkApiServices().getApi(nextPage!, LocalKeys.area);

    if (responseData != null) {
      final tempData = AreaModel.fromJson(responseData);
      for (var area in tempData.areas) {
        areaList.add(area);
      }
      nextPage = tempData.pagination?.nextPageUrl;
    } else {
      nexLoadingFailed = true;
      notifyListeners();
    }
    nextPageLoading = false;
    notifyListeners();
  }
}
