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

  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool get shouldAutoFetch => _myOrdersModel == null || token.isInvalid;

  fetchOrderList() async {
    token = getToken;
    debugPrint(token.toString());
    final url = AppUrls.myOrdersListUrl;
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.orderList, headers: commonAuthHeader);

    if (responseData != null) {
      _myOrdersModel = OrderListModel.fromJson(responseData);
      nextPage = _myOrdersModel?.pagination?.nextPageUrl;
    } else {}
    _myOrdersModel ??= OrderListModel(orders: []);
    notifyListeners();
  }

  fetchNextPage() async {
    token = getToken;
    if (nextPageLoading) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData = await NetworkApiServices()
        .getApi(nextPage, LocalKeys.orderList, headers: commonAuthHeader);

    if (responseData != null) {
      final tempData = OrderListModel.fromJson(responseData);
      for (var element in tempData.orders) {
        _myOrdersModel?.orders.add(element);
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
