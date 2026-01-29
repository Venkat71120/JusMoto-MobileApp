import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/order_models/complete_request_history_list_model.dart';

class OrderCompleteRequestHistoryService with ChangeNotifier {
  CompleteRequestHistoryListModel? _completeRequestHistoryListModel;
  CompleteRequestHistoryListModel get completeRequestHistoryListModel =>
      _completeRequestHistoryListModel ??
      CompleteRequestHistoryListModel(orderCompleteRequest: []);

  String token = "";
  String? nextPage;
  String id = "";

  bool shouldAutoFetch(id) => this.id != id.toString() || token.isInvalid;

  fetchCRH({required orderId, subOrderId}) async {
    _completeRequestHistoryListModel = null;
    token = getToken;
    id = subOrderId.toString();
    final url =
        "${AppUrls.completeRequestHistoryUrl}/order_id=${orderId.toString()}&sub_order_id=${subOrderId.toString()}";
    final responseData = await NetworkApiServices()
        .getApi(url, LocalKeys.orderDetails, headers: commonAuthHeader);

    if (responseData != null) {
      _completeRequestHistoryListModel =
          CompleteRequestHistoryListModel.fromJson(responseData);
      nextPage = _completeRequestHistoryListModel?.pagination?.nextPageUrl;
    } else {}
    notifyListeners();
  }

  tryAcceptOrder({required orderId}) async {
    var url = AppUrls.orderCancelUrl;
    var data = {
      "order_id": orderId.toString(),
    };

    final responseData = await NetworkApiServices().postApi(
        data, url, LocalKeys.cancelOrder,
        headers: acceptJsonAuthHeader);

    if (responseData != null) {
      final tempData = CompleteRequestHistoryListModel.fromJson(responseData);
      for (var h in tempData.orderCompleteRequest) {
        _completeRequestHistoryListModel?.orderCompleteRequest.add(h);
      }
      nextPage = tempData.pagination?.nextPageUrl;
      try {
        "1";
      } catch (e) {}
      notifyListeners();
      return true;
    }
  }

  tryCancelOrder({required orderId, required String action}) async {
    var url = AppUrls.orderCancelUrl;
    var data = {
      "order_id": orderId.toString(),
      "cancel_or_decline_order": action,
    };

    final responseData = await NetworkApiServices().postApi(
        data, url, LocalKeys.cancelOrder,
        headers: acceptJsonAuthHeader);

    if (responseData != null) {
      notifyListeners();
      return true;
    }
  }
}
