import 'dart:developer';

import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/address_models/address_model.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';

class AddressListService with ChangeNotifier {
  AddressListModel? _addressListModel;
  AddressListModel get addressListModel =>
      _addressListModel ?? AddressListModel(allLocations: []);

  String token = "";
  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;
  bool isLoading = false;

  bool get shouldAutoFetch => _addressListModel == null || token.isInvalid;

  fetchAddressList({bool refresh = false}) async {
    if (isLoading) return;
    token = getToken;
    if (!refresh) {
      isLoading = true;
      notifyListeners();
    }
    var url = AppUrls.addressListUrl;
    debugPrint(url.toString());

    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.jobs, headers: acceptJsonAuthHeader);

    try {
      if (responseData != null) {
        log('Address list response: ${responseData.toString()}');
        final tempData = AddressListModel.fromJson(responseData);
        _addressListModel = tempData;
        nextPage = tempData.pagination?.nextPageUrl;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        _addressListModel ??= AddressListModel(allLocations: []);
      }
    } catch (e, stackTrace) {
      debugPrint('Address list error: $e');
      log('Address list error: $e\n$stackTrace');
      _addressListModel ??= AddressListModel(allLocations: []);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  fetchNextPage() async {
    token = getToken;
    if (nextPageLoading) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData = await NetworkApiServices()
        .getApi(nextPage, LocalKeys.jobs, headers: commonAuthHeader);

    if (responseData != null) {
      final tempData = AddressListModel.fromJson(responseData);
      for (var element in tempData.allLocations) {
        _addressListModel?.allLocations.add(element);
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

  void removeAddress(id) {
    _addressListModel?.allLocations
        .removeWhere((address) => address.id.toString() == id.toString());
    notifyListeners();
  }

  reset() {
    _addressListModel = null;
  }
}
