import 'package:car_service/services/service/services_search_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceOfferViewModel {
  ScrollController scrollController = ScrollController();

  ServiceOfferViewModel._init();
  static ServiceOfferViewModel? _instance;
  static ServiceOfferViewModel get instance {
    _instance ??= ServiceOfferViewModel._init();
    return _instance!;
  }

  ServiceOfferViewModel._dispose();
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
