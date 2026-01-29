import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/payment_gateway_model.dart';

class PaymentGatewayService with ChangeNotifier {
  List<Gateway> gatewayList = [];
  Gateway? selectedGateway;
  bool isLoading = false;
  DateTime? authPayED;
  bool doAgree = false;

  bool get shouldAutoFetch => gatewayList.isEmpty;

  setSelectedGareaway(value) {
    selectedGateway = value;
    notifyListeners();
  }

  setDoAgree(value) {
    doAgree = value;
    notifyListeners();
  }

  setAuthPayED(value) {
    if (value == authPayED) {
      return;
    }
    authPayED = value;
    notifyListeners();
  }

  bool itemSelected(value) {
    if (selectedGateway == null) {
      return false;
    }
    return selectedGateway == value;
  }

  setIsLoading(value) {
    isLoading = value;
    notifyListeners();
  }

  resetGateway() {
    selectedGateway = null;
    authPayED = null;
    doAgree = false;
    notifyListeners();
  }

  fetchGateways({refresh = false}) async {
    if (gatewayList.isNotEmpty && !refresh) {
      return;
    }

    try {
      var responseData = await NetworkApiServices().getApi(
          AppUrls.paymentGatewayUrl, LocalKeys.paymentGateway,
          headers: acceptJsonAuthHeader);
      if (responseData != null) {
        final tempData = PaymentGatewayModel.fromJson(responseData);
        gatewayList = tempData.gateways;
      }
      notifyListeners();
    } catch (err) {
      debugPrint(err.toString());
    }
  }
}
