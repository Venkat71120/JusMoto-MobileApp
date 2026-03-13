import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';

import '../data/network/network_api_services.dart';
import '../models/outlet_model.dart';

class OutletService with ChangeNotifier {
  List<Outlet> outletList = [];
  bool outletLoading = false;
  String outletSearchText = '';

  bool nextPageLoading = false;

  String? nextPage;

  bool shouldAutoFetch = true;

  bool nexLoadingFailed = false;

  setOutletSearchValue(value) {
    if (value == outletSearchText) {
      return;
    }
    outletSearchText = value;
    debugPrint(outletSearchText.toString());
    fetchOutlets();
  }

  resetList() {
    debugPrint(outletSearchText.toString());
    debugPrint("resetting list".toString());
    if (outletSearchText.isEmpty && outletList.isNotEmpty) {
      debugPrint("resetting list skiped".toString());
      return;
    }
    debugPrint("resetting list in process".toString());
    outletSearchText = '';
    outletList = [];
    fetchOutlets();
  }

  fetchOutlets({autoFetching = false}) async {
    var url = "${AppUrls.outletListUrl}?search=$outletSearchText";

    if (!autoFetching) {
      outletLoading = true;
      notifyListeners();
    }
    shouldAutoFetch = false;
    final responseData =
        await NetworkApiServices().getApi(url, LocalKeys.outlet);
    try {
      if (responseData != null) {
        final tempData = OutletModel.fromJson(responseData);

        outletList = tempData.allOutlets ?? [];
        nextPage = tempData.pagination?.nextPageUrl;
        return true;
      }
    } finally {
      outletLoading = false;
      notifyListeners();
    }
  }

  fetchNextPage() async {
    if (nextPageLoading) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData =
        await NetworkApiServices().getApi(nextPage!, LocalKeys.outlet);

    if (responseData != null) {
      final tempData = OutletModel.fromJson(responseData);

      nextPage = tempData.pagination?.nextPageUrl;
      for (var element in tempData.allOutlets ?? []) {
        outletList.add(element);
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
