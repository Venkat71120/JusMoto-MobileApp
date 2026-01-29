import 'package:car_service/services/service/services_search_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceResultViewModel {
  ScrollController scrollController = ScrollController();

  ServiceResultViewModel._init();
  static ServiceResultViewModel? _instance;
  static ServiceResultViewModel get instance {
    _instance ??= ServiceResultViewModel._init();
    return _instance!;
  }

  ServiceResultViewModel._dispose();
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
