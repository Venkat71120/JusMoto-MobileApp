import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/payment_gateway_model.dart';
import '../../view_models/service_booking_view_model/service_booking_view_model.dart';

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

        // Auto-select COD if available or if there's only one gateway
        if (gatewayList.isNotEmpty) {
          final sbm = ServiceBookingViewModel.instance;
          
          // Look for COD specifically
          final codGateway = gatewayList.firstWhere(
            (g) => ["cash_on_delivery", "cod"].contains(g.name?.toLowerCase()),
            orElse: () => gatewayList.length == 1 ? gatewayList.first : Gateway(testMode: false),
          );

          if (codGateway.name != null) {
            selectedGateway = codGateway;
            sbm.selectedGateway.value = codGateway;
          }
        }
      }
      notifyListeners();
    } catch (err) {
      debugPrint(err.toString());
    }
  }
}
