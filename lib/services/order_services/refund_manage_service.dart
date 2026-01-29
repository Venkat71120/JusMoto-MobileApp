import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/view_models/refund_list_view_model/refund_list_view_model.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/order_models/refund_details_model.dart';

class RefundManageService with ChangeNotifier {
  RefundDetailsModel? _refundDetailsModel;
  RefundDetailsModel get refundDetailsModel =>
      _refundDetailsModel ?? RefundDetailsModel();
  var token = "";

  var refundId;

  bool nextPageLoading = false;

  bool nexLoadingFailed = false;

  bool shouldAutoFetch(id) =>
      id.toString() != refundId?.toString() || token.isInvalid;

  fetchRefundDetails({id}) async {
    refundId = id;
    token = getToken;
    final url = "${AppUrls.myRefundDetailsUrl}/$id";
    final responseData = await NetworkApiServices().getApi(
      url,
      LocalKeys.orderList,
      headers: commonAuthHeader,
    );

    if (responseData != null) {
      _refundDetailsModel = RefundDetailsModel.fromJson(responseData);
    } else {
      _refundDetailsModel = null;
    }
    notifyListeners();
  }

  tryUpdatingPaymentInfo() async {
    var url = AppUrls.refundInfoUpdateUrl;
    final rlm = RefundListViewModel.instance;
    final gatewayFields = rlm.selectedGateway.value!.field;
    final fieldValues = {};
    for (var i = 0; i < gatewayFields.length; i++) {
      fieldValues.putIfAbsent(
        gatewayFields[i].toLowerCase().replaceAll(" ", "_"),
        () => rlm.inputFieldControllers[i].text,
      );
    }
    var data = {
      'refund_id': refundDetailsModel.refundDetails?.id?.toString() ?? "",
      'gateway_id': rlm.selectedGateway.value!.id.toString(),
      'gateway_fields': jsonEncode(fieldValues),
      "order_id": refundDetailsModel.refundDetails?.order?.id?.toString() ?? "",
    };

    final responseData = await NetworkApiServices().postApi(
      data,
      url,
      LocalKeys.cancelOrder,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      LocalKeys.infoUpdatedSuccessfully.showToast();
      rlm.refreshKey.currentState?.show();
      notifyListeners();
      return true;
    }
    return false;
  }
}
