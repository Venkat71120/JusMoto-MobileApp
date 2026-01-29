import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/category_model.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/constant_helper.dart';
import '../../models/home_models/services_list_model.dart';

class ProductListService with ChangeNotifier {
  ServiceListModel? _searchResultModel;
  ServiceListModel get searchResultModel =>
      _searchResultModel ?? ServiceListModel(allServices: []);

  Category? selectedCategory;
  num? minPrice;
  num? maxPrice;
  double? ratingCount;
  String? title;

  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;
  bool isLoading = false;

  String get getFilter {
    String param =
        "?variant_id=${sPref?.getString("vId")}&title=${title ?? ""}";
    if (selectedCategory?.id != null) {
      param = "&${param}cat_id=${selectedCategory!.id}";
    }
    if ((minPrice ?? 0) > 0) {
      param = "&${param}min_price=$minPrice";
    }
    if ((maxPrice ?? 0) > 0) {
      param = "&${param}max_price=$maxPrice";
    }
    if ((ratingCount ?? 0) > 0) {
      param = "&${param}rating=${ratingCount!.toInt()}";
    }
    return param;
  }

  setFilters({
    Category? selectedCategory,
    num? minPrice,
    num? maxPrice,
    double? ratingCount,
  }) {
    this.selectedCategory = selectedCategory;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    this.ratingCount = ratingCount;

    fetchProductListServices();
  }

  bool get shouldAutoFetch => _searchResultModel?.allServices == null;

  fetchProductListServices({refreshing = false}) async {
    var url = "${AppUrls.serviceListUrl}$getFilter";
    if (!refreshing) {
      isLoading = true;
      notifyListeners();
    }
    final responseData =
        await NetworkApiServices().getApi(url, LocalKeys.searchService);

    try {
      if (responseData != null) {
        final tempData = ServiceListModel.fromJson(responseData);
        _searchResultModel = tempData;
        nextPage = tempData.pagination?.nextPageUrl;
      } else {
        _searchResultModel ??= ServiceListModel(allServices: []);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  fetchNextPage() async {
    if (nextPageLoading) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData =
        await NetworkApiServices().getApi(nextPage, LocalKeys.jobs);

    if (responseData != null) {
      final tempData = ServiceListModel.fromJson(responseData);
      for (var element in tempData.allServices) {
        _searchResultModel?.allServices.add(element);
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

  void setSearchTitle(String text) {
    title = text;

    fetchProductListServices();
  }
}
