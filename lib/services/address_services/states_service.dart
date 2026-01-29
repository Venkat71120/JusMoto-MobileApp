import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/address_models/states_model.dart';

class StatesService with ChangeNotifier {
  bool stateLoading = false;
  String stateSearchText = '';

  List<States?> stateDropdownList = [];

  bool nextPageLoading = false;

  String? nextPage;

  bool nexLoadingFailed = false;

  setStatesSearchValue(value) {
    if (value == stateSearchText) {
      return;
    }
    stateSearchText = value;
  }

  resetList() {
    if (stateSearchText.isEmpty && stateDropdownList.isNotEmpty) {
      return;
    }
    stateSearchText = '';
    stateDropdownList = [];
    getStates();
  }

  void getStates() async {
    stateLoading = true;
    nextPage = null;
    notifyListeners();
    final url = "${AppUrls.statesUrl}?q=$stateSearchText";
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.state, headers: commonAuthHeader);

    if (responseData != null) {
      final tempData = StatesModel.fromJson(responseData);
      stateDropdownList = tempData.states;
      nextPage = tempData.pagination?.nextPageUrl;
    } else {}

    stateLoading = false;
    notifyListeners();
  }

  fetchNextPage() async {
    if (nextPageLoading || nextPage == null) return;
    nextPageLoading = true;
    final responseData =
        await NetworkApiServices().getApi(nextPage!, LocalKeys.state);

    if (responseData != null) {
      final tempData = StatesModel.fromJson(responseData);
      for (var city in tempData.states) {
        stateDropdownList.add(city);
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
