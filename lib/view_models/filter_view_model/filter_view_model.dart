import 'dart:async';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/service/service_unit_model.dart';
import 'package:car_service/services/service/services_search_service.dart';
import 'package:car_service/view_models/order_list_view_model/order_status_enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';

class FilterViewModel {
  TextEditingController searchController = TextEditingController();

  ValueNotifier<SearchType> selectedType = ValueNotifier(SearchType.all);
  ValueNotifier<Category?> selectedCategory = ValueNotifier(null);
  ValueNotifier<ServiceUnit?> selectedUnit = ValueNotifier(null);
  ValueNotifier<double?> ratingCount = ValueNotifier(null);
  ValueNotifier<RangeValues> priceRange = ValueNotifier(
    const RangeValues(0, 3000),
  );

  Timer? timer;

  FilterViewModel._init();
  static FilterViewModel? _instance;
  static FilterViewModel get instance {
    _instance ??= FilterViewModel._init();
    return _instance!;
  }

  FilterViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  initFilters(BuildContext context) {
    final ss = Provider.of<ServicesSearchService>(context, listen: false);
    selectedCategory.value = ss.selectedCategory;
    searchController.text = ss.title ?? "";
    ratingCount.value = ss.ratingCount;
    selectedType.value = ss.searchType;
    priceRange.value = RangeValues(
      ss.minPrice?.toDouble() ?? 0,
      ss.maxPrice?.toDouble() ?? 0,
    );
  }

  setFilters(BuildContext context) {
    final ss = Provider.of<ServicesSearchService>(context, listen: false);

    ss.setFilters(
      selectedCategory: selectedCategory.value,
      minPrice: priceRange.value.start.toString().tryToParse,
      maxPrice: priceRange.value.end.toString().tryToParse,
      ratingCount: ratingCount.value,
      searchType: selectedType.value,
    );
  }

  void reset(BuildContext context) {
    final ss = Provider.of<ServicesSearchService>(context, listen: false);

    ss.setFilters();
  }
}

enum SearchType { all, service, product }

final typeValues = EnumValues({
  "0": SearchType.all,
  "1": SearchType.service,
  "2": SearchType.product,
});
