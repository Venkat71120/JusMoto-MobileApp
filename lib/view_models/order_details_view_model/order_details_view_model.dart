import 'package:flutter/material.dart';

import '../../services/order_services/refund_settings_service.dart';

class OrderDetailsViewModel {
  final ValueNotifier selectedGateway = ValueNotifier(null);
  final TextEditingController reasonController = TextEditingController();
  List<TextEditingController> inputFieldControllers = [];

  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  setSelectedGateway(RefundSettingsService rw, value) {
    final gateway = rw.withdrawSettingsModel.withdrawGateways
        .firstWhere((element) => element.name == value);
    selectedGateway.value = gateway;
    inputFieldControllers.clear();
    for (var g in gateway.field) {
      inputFieldControllers.add(TextEditingController());
    }
  }

  OrderDetailsViewModel._init();
  static OrderDetailsViewModel? _instance;
  static OrderDetailsViewModel get instance {
    _instance ??= OrderDetailsViewModel._init();
    return _instance!;
  }

  OrderDetailsViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  tryCancellingOrder(BuildContext context) {}
}
