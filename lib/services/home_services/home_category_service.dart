import 'dart:convert';

import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/constant_helper.dart';
import '../../models/category_model.dart';

class HomeCategoryService with ChangeNotifier {
  List<Category>? categoryList;

  initLocal() {
    final localData = sPref?.getString("home_categories");
    final tempData = CategoryListModel.fromJson(jsonDecode(localData ?? "{}"));
    if ((tempData.categories ?? []).isNotEmpty) {
      categoryList = tempData.categories;
      fetchCategories();
    }
  }

  fetchCategories() async {
    // ✅ UPDATED: Uses new /categories endpoint
    // sort_by=id avoids backend bug: "Unknown column 'Category.order' in order clause"
    final url = Uri.parse(AppUrls.homeCategoryListUrl)
        .replace(queryParameters: {
          'status': '1',
          'sort_by': 'id',
          'sort_order': 'ASC',
        })
        .toString();

    final responseData =
        await NetworkApiServices().getApi(url, LocalKeys.category);
    try {
      if (responseData != null) {
        final tempData = CategoryListModel.fromJson(responseData);
        categoryList = tempData.categories ?? [];
        sPref?.setString("home_categories", jsonEncode(responseData));
      }
    } finally {
      categoryList ??= [];
      notifyListeners();
    }
  }
}