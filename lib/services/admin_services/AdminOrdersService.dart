import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/admin_order_model.dart';
import '../../helper/extension/string_extension.dart';

class AdminOrdersService extends ChangeNotifier {
  AdminOrderListModel _orderList = AdminOrderListModel.empty();
  AdminOrderListModel get orderList => _orderList;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchOrders({
    int page = 1,
    String? search,
    String? status,
    String? paymentStatus,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      String url = '${AppUrls.adminOrdersUrl}?page=$page&limit=15';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (status != null && status.isNotEmpty) url += '&status=$status';
      if (paymentStatus != null && paymentStatus.isNotEmpty) url += '&payment_status=$paymentStatus';

      final response = await NetworkApiServices().getApi(
        url,
        "Admin Orders List",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        _orderList = AdminOrderListModel.fromJson(Map<String, dynamic>.from(response));
        debugPrint('✅ Admin Orders fetched successfully');
      } else {
        debugPrint('❌ Failed to fetch Admin Orders');
        "Failed to load order list".showToast();
      }
    } catch (e) {
      debugPrint('❌ Exception fetching Admin Orders: $e');
      "Error: $e".showToast();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(int orderId, int newStatus) async {
    try {
      final response = await NetworkApiServices().putApi(
        {'status': newStatus},
        '${AppUrls.adminOrdersUrl}/$orderId/status',
        "Update Order Status",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        // Update local state for immediate feedback
        final index = _orderList.orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orderList.orders[index] = _orderList.orders[index].copyWith(statusCode: newStatus);
          notifyListeners();
        }
        "Order status updated".showToast();
        return true;
      } else {
        "Failed to update status".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
      "Error: $e".showToast();
      return false;
    }
  }

  Future<bool> updatePaymentStatus(int orderId, int newStatus) async {
    try {
      final response = await NetworkApiServices().putApi(
        {'payment_status': newStatus},
        '${AppUrls.adminOrdersUrl}/$orderId/payment-status',
        "Update Payment Status",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        // Update local state for immediate feedback
        final index = _orderList.orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orderList.orders[index] = _orderList.orders[index].copyWith(paymentStatusCode: newStatus);
          notifyListeners();
        }
        "Payment status updated".showToast();
        return true;
      } else {
        "Failed to update payment status".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating payment: $e');
      "Error: $e".showToast();
      return false;
    }
  }
}
