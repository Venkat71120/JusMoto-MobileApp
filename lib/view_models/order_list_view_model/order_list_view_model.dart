import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/order_services/order_list_service.dart';
import 'order_status_enums.dart';

class OrderListViewModel {
  ScrollController scrollController = ScrollController();

  final ValueNotifier<Set<StatusType>> statusType =
      ValueNotifier({StatusType.all});
  final ValueNotifier<BookingStatus?> bookingStatus = ValueNotifier(null);
  final ValueNotifier<PaymentStatus?> paymentStatus = ValueNotifier(null);

  final TextEditingController declineReasonController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey();

  OrderListViewModel._init();
  static OrderListViewModel? _instance;
  static OrderListViewModel get instance {
    _instance ??= OrderListViewModel._init();
    return _instance!;
  }

  setStatusType(Set<StatusType> value) {
    if (value.contains(StatusType.all) &&
        !statusType.value.contains(StatusType.all)) {
      statusType.value = {StatusType.all};
      bookingStatus.value = null;
      paymentStatus.value = null;
      return;
    }
    if (!value.contains(StatusType.booking)) {
      bookingStatus.value = null;
    }
    if (!value.contains(StatusType.payment)) {
      paymentStatus.value = null;
    }
    final tempValue = value.toList().toSet();
    tempValue.remove(StatusType.all);
    statusType.value = tempValue;
  }

  setBookingStatus(value) {
    bookingStatus.value = value.first;
  }

  setPaymentStatus(value) {
    paymentStatus.value = value.first;
  }

  double get appBarExpandedHeight {
    if (statusType.value.contains(StatusType.all)) {
      return 0;
    }
    if (statusType.value.length == 1) {
      return 96;
    }
    return 144;
  }

  OrderListViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  tryToLoadMore(BuildContext context) {
    try {
      final moProvider = Provider.of<OrderListService>(context, listen: false);

      // ✅ UPDATED: nextPage is now int? — check for non-null instead of URL string
      final nextPage = moProvider.nextPage;
      final nextPageLoading = moProvider.nextPageLoading;

      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (nextPage != null && !nextPageLoading) {
          moProvider.fetchNextPage();
          return;
        }
      }
    } catch (e) {}
  }
}