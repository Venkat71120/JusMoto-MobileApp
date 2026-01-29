import 'package:car_service/services/order_services/refund_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/order_services/refund_list_service.dart';

class RefundListViewModel {
  ValueNotifier selectedGateway = ValueNotifier(null);
  final TextEditingController reasonController = TextEditingController();
  List<TextEditingController> inputFieldControllers = [];
  final ScrollController scrollController = ScrollController();
  final ScrollController dScrollController = ScrollController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  RefundListViewModel._init();
  static RefundListViewModel? _instance;
  static RefundListViewModel get instance {
    _instance ??= RefundListViewModel._init();
    return _instance!;
  }

  RefundListViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  setSelectedGateway(RefundSettingsService rw, value) {
    final gateway = rw.withdrawSettingsModel.withdrawGateways
        .firstWhere((element) => element.name == value);
    selectedGateway.value = gateway;
    inputFieldControllers.clear();
    for (var g in gateway.field) {
      inputFieldControllers.add(TextEditingController());
    }
  }

  tryToLoadMore(BuildContext context) {
    try {
      final rm = Provider.of<RefundListService>(context, listen: false);
      final nextPage = rm.nextPage;
      final nextPageLoading = rm.nextPageLoading;

      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (nextPage != null && !nextPageLoading) {
          rm.fetchNextPage();
          return;
        }
      }
    } catch (e) {}
  }
}
