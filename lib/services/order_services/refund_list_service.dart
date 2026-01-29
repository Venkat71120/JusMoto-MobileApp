import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/order_models/refund_list_model.dart';

class RefundListService with ChangeNotifier {
  RefundListModel? _notificationListModel;
  RefundListModel get notificationListModel =>
      _notificationListModel ?? RefundListModel();
  var token = "";

  var nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool get shouldAutoFetch => _notificationListModel == null || token.isInvalid;

  fetchRefundList() async {
    token = getToken;
    final url = AppUrls.myRefundListUrl;
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.orderList, headers: commonAuthHeader);

    if (responseData != null) {
      _notificationListModel = RefundListModel.fromJson(responseData);
      nextPage = _notificationListModel?.pagination?.nextPageUrl;
    } else {}
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
      final tempData = RefundListModel.fromJson(responseData);
      for (var element in (tempData.clientAllRefundList ?? [])) {
        _notificationListModel?.clientAllRefundList?.add(element);
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
