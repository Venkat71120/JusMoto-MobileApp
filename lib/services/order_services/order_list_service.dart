import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/order_models/order_list_model.dart';

class OrderListService with ChangeNotifier {
  OrderListModel? _myOrdersModel;
  OrderListModel get myOrdersModel =>
      _myOrdersModel ?? OrderListModel(orders: []);

  var token = "";

  // ✅ UPDATED: nextPage is now an int (page number) instead of a URL string
  int? _nextPageNumber;
  int? get nextPage => _nextPageNumber;

  bool nextPageLoading = false;
  bool nexLoadingFailed = false;

  bool get shouldAutoFetch => _myOrdersModel == null || token.isInvalid;

  // ✅ UPDATED: URL now includes status, page, limit query params
  String _buildUrl({int page = 1, int limit = 10, int? status}) {
    final base = AppUrls.myOrdersListUrl;
    final params = <String>['page=$page', 'limit=$limit'];
    if (status != null) params.add('status=$status');
    return '$base?${params.join('&')}';
  }

  fetchOrderList({int? status}) async {
    token = getToken;
    debugPrint(token.toString());

    final url = _buildUrl(status: status);
    debugPrint('fetchOrderList URL: $url');

    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.orderList, headers: commonAuthHeader);

    if (responseData != null) {
      _myOrdersModel = OrderListModel.fromJson(responseData);

      // ✅ UPDATED: Derive next page number from new pagination shape
      final pagination = _myOrdersModel?.pagination;
      if (pagination != null && pagination.hasNextPage) {
        _nextPageNumber = pagination.page + 1;
      } else {
        _nextPageNumber = null;
      }

      debugPrint(
          'Loaded ${_myOrdersModel?.orders.length} orders. Next page: $_nextPageNumber');
    }

    _myOrdersModel ??= OrderListModel(orders: []);
    notifyListeners();
  }

  fetchNextPage({int? status}) async {
    token = getToken;
    if (nextPageLoading || _nextPageNumber == null) return;

    nextPageLoading = true;
    notifyListeners();

    final pagination = _myOrdersModel?.pagination;
    final limit = pagination?.limit ?? 10;

    final url = _buildUrl(page: _nextPageNumber!, limit: limit, status: status);
    debugPrint('fetchNextPage URL: $url');

    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.orderList, headers: commonAuthHeader);

    if (responseData != null) {
      final tempData = OrderListModel.fromJson(responseData);

      for (var element in tempData.orders) {
        _myOrdersModel?.orders.add(element);
      }

      // ✅ UPDATED: Advance or clear next page number
      if (tempData.pagination != null && tempData.pagination!.hasNextPage) {
        _nextPageNumber = tempData.pagination!.page + 1;
      } else {
        _nextPageNumber = null;
      }
    } else {
      nexLoadingFailed = true;
      Future.delayed(const Duration(seconds: 1)).then((_) {
        nexLoadingFailed = false;
        notifyListeners();
      });
    }

    nextPageLoading = false;
    notifyListeners();
  }
}