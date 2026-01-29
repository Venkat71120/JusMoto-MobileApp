import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../models/order_models/order_response_model.dart';
import '../../view_models/order_details_view_model/order_details_view_model.dart';

class OrderDetailsService with ChangeNotifier {
  OrderResponseModel? _orderDetailsModel;
  OrderResponseModel get orderDetailsModel =>
      _orderDetailsModel ?? OrderResponseModel();

  String token = "";
  String id = "";

  bool shouldAutoFetch(id) => id.toString() != this.id || token.isInvalid;

  fetchOrderDetails({required orderId}) async {
    _orderDetailsModel = null;
    token = getToken;
    id = orderId.toString();
    final url = "${AppUrls.orderDetailsUrl}/${orderId.toString()}";
    final responseData = await NetworkApiServices().getApi(
      url,
      LocalKeys.orderDetails,
      headers: commonAuthHeader,
    );

    if (responseData != null) {
      _orderDetailsModel = OrderResponseModel.fromJson(responseData);
    } else {}
    notifyListeners();
  }

  tryCancelOrder() async {
    var url = AppUrls.orderCancelUrl;
    final odm = OrderDetailsViewModel.instance;
    final gatewayFields = odm.selectedGateway.value?.field ?? [];
    final fieldValues = {};
    for (var i = 0; i < gatewayFields.length; i++) {
      fieldValues.putIfAbsent(
        gatewayFields[i].toLowerCase().replaceAll(" ", "_"),
        () => odm.inputFieldControllers[i].text,
      );
    }
    var data = {
      'gateway_id': odm.selectedGateway.value?.id.toString() ?? "",
      'gateway_fields': jsonEncode(fieldValues),
      "order_id": orderDetailsModel.orderDetails?.id?.toString() ?? "",
    };

    final responseData = await NetworkApiServices().postApi(
      data,
      url,
      LocalKeys.cancelOrder,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      LocalKeys.orderCancelledSuccessfully.showToast();
      odm.refreshKey.currentState?.show();
      notifyListeners();
      return true;
    }
    return false;
  }
}
