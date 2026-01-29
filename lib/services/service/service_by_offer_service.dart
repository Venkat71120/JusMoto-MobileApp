import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/constant_helper.dart';
import '../../models/home_models/offer_service_list_model.dart';

class ServiceByOfferService with ChangeNotifier {
  OfferServiceListModel? _serviceByOfferModel;
  OfferServiceListModel get serviceByOfferModel =>
      _serviceByOfferModel ?? OfferServiceListModel(allServices: []);

  String? nextPage;

  dynamic offerId;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;
  bool isLoading = false;

  bool shouldAutoFetch(id) => id.toString() != offerId.toString();

  fetchServices({refreshing = false, offerId}) async {
    try {
      var url =
          "${AppUrls.serviceListByOfferUrl}/$offerId?variant_id=${sPref?.getString("vId")}";
      this.offerId = offerId;
      final responseData =
          await NetworkApiServices().getApi(url, LocalKeys.searchService);

      if (responseData != null) {
        final tempData = OfferServiceListModel.fromJson(responseData);
        _serviceByOfferModel = tempData;
        nextPage = tempData.pagination?.nextPageUrl;
      } else {
        _serviceByOfferModel ??= OfferServiceListModel(allServices: []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
    debugPrint(serviceByOfferModel.allServices.toString());
  }

  fetchNextPage() async {
    if (nextPageLoading || nextPage == null) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData =
        await NetworkApiServices().getApi(nextPage!, LocalKeys.jobs);

    if (responseData != null) {
      final tempData = OfferServiceListModel.fromJson(responseData);
      for (var element in tempData.allServices) {
        _serviceByOfferModel?.allServices.add(element);
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
