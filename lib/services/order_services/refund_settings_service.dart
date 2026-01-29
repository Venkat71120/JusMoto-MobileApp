import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/order_models/refund_settings_model.dart';
import '../../view_models/refund_list_view_model/refund_list_view_model.dart';

class RefundSettingsService with ChangeNotifier {
  RefundSettingsModel? _withdrawSettings;
  RefundSettingsModel get withdrawSettingsModel =>
      _withdrawSettings ??
      RefundSettingsModel(
        withdrawGateways: [],
      );

  String token = "";

  bool get shouldAutoFetch => _withdrawSettings == null || token.isInvalid;

  fetchWithdrawSettings() async {
    var url = AppUrls.refundPaymentMethodsUrl;
    token = getToken;

    final responseData = await NetworkApiServices().getApi(
      url,
      LocalKeys.refundPaymentMethod,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      _withdrawSettings = RefundSettingsModel.fromJson(responseData);
      return true;
    }
  }

  tryWithdrawRequest() async {
    var url = AppUrls.updateRefundPaymentInfoUrl;
    try {
      final wrm = RefundListViewModel.instance;
      final gatewayFields = wrm.selectedGateway.value!.field;
      final fieldValues = {};
      for (var i = 0; i < gatewayFields.length; i++) {
        fieldValues.putIfAbsent(
            gatewayFields[i].toLowerCase().replaceAll(" ", "_"),
            () => wrm.inputFieldControllers[i].text);
      }
      var data = {
        'gateway_id': wrm.selectedGateway.value!.id.toString(),
        'gateway_fields': jsonEncode(fieldValues),
      };

      debugPrint(data.toString());

      final responseData = await NetworkApiServices().postApi(
          data, url, LocalKeys.updateRefundInfo,
          headers: acceptJsonAuthHeader);

      if (responseData != null) {
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
