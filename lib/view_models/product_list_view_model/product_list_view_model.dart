import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/service/services_search_service.dart';

class ProductListViewModel {
  ScrollController scrollController = ScrollController();

  ProductListViewModel._init();
  static ProductListViewModel? _instance;
  static ProductListViewModel get instance {
    _instance ??= ProductListViewModel._init();
    return _instance!;
  }

  ProductListViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  tryToLoadMore(BuildContext context) {
    try {
      final ss = Provider.of<ServicesSearchService>(context, listen: false);
      final nextPage = ss.nextPage;
      final nextPageLoading = ss.nextPageLoading;

      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (nextPage != null && !nextPageLoading) {
          ss.fetchNextPage();
          return;
        }
      }
    } catch (e) {}
  }
}
