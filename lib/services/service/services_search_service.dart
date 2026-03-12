import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/category_model.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../models/home_models/services_list_model.dart';
import '../../view_models/filter_view_model/filter_view_model.dart';

class ServicesSearchService with ChangeNotifier {
  ServiceListModel? _searchResultModel;
  ServiceListModel get searchResultModel =>
      _searchResultModel ?? ServiceListModel(allServices: []);

  Category? selectedCategory;
  num? minPrice;
  num? maxPrice;
  double? ratingCount;
  String? title;
  SearchType searchType = SearchType.all;

  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;
  bool isLoading = false;

  Map<String, String> get getFilter {
    final params = <String, String>{};

    final vId = sPref?.getString("vId") ?? '';
    if (vId.isNotEmpty) params['variant_id'] = vId;

    if (title != null && title!.isNotEmpty) {
      params['search'] = title!;
    }

    if (selectedCategory?.id != null) {
      params['category_id'] = selectedCategory!.id.toString();
    }
    
    if (minPrice != null) {
      params['min_price'] = minPrice.toString();
    }
    
    if ((maxPrice ?? 0) > 0) {
      params['max_price'] = maxPrice.toString();
    }
    
    if ((ratingCount ?? 0) > 0) {
      params['rating'] = ratingCount!.toInt().toString();
    }

    if (searchType == SearchType.service) {
      params['type'] = '0';
    } else if (searchType == SearchType.product) {
      params['type'] = '1';
    }

    return params;
  }

  setFilters({
    Category? selectedCategory,
    num? minPrice,
    num? maxPrice,
    double? ratingCount,
    SearchType? searchType,
  }) {
    this.selectedCategory = selectedCategory;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    this.ratingCount = ratingCount;
    this.searchType = searchType ?? SearchType.all;

    fetchHomeFeaturedServices();
  }

  resetFilters() {
    selectedCategory = null;
    minPrice = null;
    maxPrice = null;
    ratingCount = null;
    searchType = SearchType.all;
  }

  bool get shouldAutoFetch => _searchResultModel?.allServices == null;

  fetchHomeFeaturedServices({refreshing = false}) async {
    var url = Uri.parse(AppUrls.serviceListUrl)
        .replace(queryParameters: getFilter)
        .toString();
    if (!refreshing) {
      isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
    final responseData = await NetworkApiServices().getApi(
      url,
      LocalKeys.searchService,
    );

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  fetchNextPage() async {
    if (nextPageLoading) return;
    nextPageLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final responseData = await NetworkApiServices().getApi(
      "$nextPage&variant_id=${sPref?.getString("vId")}",
      LocalKeys.jobs,
    );

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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      });
    }
    nextPageLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void setSearchTitle(String text) {
    title = text;

    fetchHomeFeaturedServices();
  }
}
