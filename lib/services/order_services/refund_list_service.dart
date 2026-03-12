import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/order_models/refund_list_model.dart';

class RefundListService with ChangeNotifier {
  RefundListModel? _refundListModel;
  RefundListModel get refundListModel =>
      _refundListModel ?? RefundListModel();
  var token = "";

  String? nextPage;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool get shouldAutoFetch => _refundListModel == null || token.isInvalid;

  fetchRefundList() async {
    token = getToken;
    final url = AppUrls.myRefundListUrl;
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.orderList, headers: commonAuthHeader);

    if (responseData != null) {
      _refundListModel = RefundListModel.fromJson(responseData);
      nextPage = _refundListModel?.pagination?.nextPageUrl(AppUrls.myRefundListUrl);
    } else {}
    notifyListeners();
  }

  fetchNextPage() async {
    token = getToken;
    if (nextPageLoading || nextPage == null) return;
    nextPageLoading = true;
    notifyListeners();
    final responseData = await NetworkApiServices()
        .getApi(nextPage!, LocalKeys.orderList, headers: commonAuthHeader);

    if (responseData != null) {
      final tempData = RefundListModel.fromJson(responseData);
      if (_refundListModel?.clientAllRefundList != null) {
        _refundListModel!.clientAllRefundList!
            .addAll(tempData.clientAllRefundList ?? []);
      } else {
        _refundListModel = tempData;
      }
      nextPage = tempData.pagination?.nextPageUrl(AppUrls.myRefundListUrl);
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

