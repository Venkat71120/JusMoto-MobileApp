import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/local_keys.g.dart';
import '../../models/address_models/city_model.dart';

class CityService with ChangeNotifier {
  bool cityLoading = false;
  String citySearchText = '';
  dynamic stateId;

  List<City?> cityList = [];

  bool nextPageLoading = false;

  String? nextPage;

  bool nexLoadingFailed = false;

  setCitySearchValue(value) {
    if (value == citySearchText) {
      return;
    }
    citySearchText = value;
    notifyListeners();
  }

  resetList(cId) {
    if (citySearchText.isEmpty && cityList.isNotEmpty && cId == stateId) {
      return;
    }
    citySearchText = '';
    stateId = cId;
    cityList = [];
    getCity();
  }

  void getCity() async {
    cityLoading = true;
    nextPage = null;
    notifyListeners();
    final url = "${AppUrls.cityUrl}/$stateId?search=$citySearchText";
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.city);

    if (responseData != null) {
      final tempData = CityModel.fromJson(responseData);
      cityList = tempData.cities;
      nextPage = tempData.pagination?.nextPageUrl;
    } else {}

    cityLoading = false;
    notifyListeners();
  }

  fetchNextPage() async {
    if (nextPageLoading || nextPage == null) return;
    nextPageLoading = true;

    final responseData =
        await NetworkApiServices().getApi(nextPage!, LocalKeys.city);

    if (responseData != null) {
      final tempData = CityModel.fromJson(responseData);
      for (var city in tempData.cities) {
        cityList.add(city);
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
