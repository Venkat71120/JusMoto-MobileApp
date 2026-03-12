import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';

import '../data/network/network_api_services.dart';
import '../models/category_model.dart';

class CategoryService with ChangeNotifier {
  List<Category> categoryList = [];
  bool categoryLoading = false;
  String categorySearchText = '';

  bool nextPageLoading = false;

  String? nextPage;

  bool shouldAutoFetch = true;

  bool nexLoadingFailed = false;

  setCategorySearchValue(value) {
    if (value == categorySearchText) {
      return;
    }
    categorySearchText = value;
    debugPrint(categorySearchText.toString());
    fetchCategories();
  }

  resetList() {
    debugPrint(categorySearchText.toString());
    debugPrint("resetting list".toString());
    if (categorySearchText.isEmpty && categoryList.isNotEmpty) {
      debugPrint("resetting list skiped".toString());
      return;
    }
    debugPrint("resetting list in process".toString());
    categorySearchText = '';
    categoryList = [];
    fetchCategories();
  }

  fetchCategories({autoFetching = false}) async {
    final url = Uri.parse(AppUrls.categoryListUrl)
        .replace(queryParameters: {
          'name': categorySearchText,
          'status': '1',
          'sort_by': 'id',
          'sort_order': 'ASC',
        })
        .toString();

    if (!autoFetching) {
      categoryLoading = true;
      notifyListeners();
    }
    shouldAutoFetch = false;
    final responseData =
        await NetworkApiServices().getApi(url, LocalKeys.category);
    try {
      if (responseData != null) {
        final tempData = CategoryListModel.fromJson(responseData);

        categoryList = tempData.categories ?? [];
        nextPage = tempData.pagination?.nextPageUrl;
        return true;
      }
    } finally {
      categoryLoading = false;
      notifyListeners();
    }
  }

  fetchNextPage() async {
    if (nextPageLoading) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData =
        await NetworkApiServices().getApi(nextPage!, LocalKeys.category);

    if (responseData != null) {
      final tempData = CategoryListModel.fromJson(responseData);

      nextPage = tempData.pagination?.nextPageUrl;
      for (var element in tempData.categories ?? []) {
        categoryList.add(element);
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
