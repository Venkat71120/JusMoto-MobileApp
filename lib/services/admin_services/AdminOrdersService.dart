import 'dart:convert';
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

  // ── Order Detail State ──────────────────────────────────────────────────────
  AdminOrderDetailModel? _orderDetail;
  AdminOrderDetailModel? get orderDetail => _orderDetail;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  bool _hasDetailError = false;
  bool get hasDetailError => _hasDetailError;

  // ── Franchise List State ────────────────────────────────────────────────────
  List<AdminFranchiseItem> _franchiseList = [];
  List<AdminFranchiseItem> get franchiseList => _franchiseList;

  bool _isLoadingFranchises = false;
  bool get isLoadingFranchises => _isLoadingFranchises;

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

  // ── Fetch Order Detail ──────────────────────────────────────────────────────
  Future<void> fetchOrderDetail(int orderId) async {
    if (_isLoadingDetail) return;

    _isLoadingDetail = true;
    _hasDetailError = false;
    _orderDetail = null;
    notifyListeners();

    try {
      final url = '${AppUrls.adminOrderDetailsUrl}/$orderId';
      final response = await NetworkApiServices().getApi(
        url,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );

      if (response != null) {
        _orderDetail = AdminOrderDetailModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      } else {
        _hasDetailError = true;
      }
    } catch (e) {
      debugPrint('❌ AdminOrdersService.fetchOrderDetail: $e');
      _hasDetailError = true;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void clearDetail() {
    _orderDetail = null;
    _hasDetailError = false;
    notifyListeners();
  }

  // ── Update Order Status (from detail page) ─────────────────────────────────
  Future<bool> updateOrderStatusFromDetail(int orderId, int newStatus) async {
    final result = await updateOrderStatus(orderId, newStatus);
    if (result) {
      // Refresh detail to reflect changes
      await fetchOrderDetail(orderId);
    }
    return result;
  }

  // ── Update Payment Status (from detail page) ──────────────────────────────
  Future<bool> updatePaymentStatusFromDetail(int orderId, int newStatus) async {
    final result = await updatePaymentStatus(orderId, newStatus);
    if (result) {
      await fetchOrderDetail(orderId);
    }
    return result;
  }

  // ── Fetch Franchise List ───────────────────────────────────────────────────
  Future<void> fetchFranchiseList() async {
    if (_isLoadingFranchises) return;
    _isLoadingFranchises = true;
    notifyListeners();

    try {
      final response = await NetworkApiServices().getApi(
        '${AppUrls.adminFranchisesUrl}?limit=100',
        null,
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        final list = response['data'] as List? ?? [];
        _franchiseList = list
            .map((f) => AdminFranchiseItem.fromJson(
                Map<String, dynamic>.from(f)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching franchises: $e');
    } finally {
      _isLoadingFranchises = false;
      notifyListeners();
    }
  }

  // ── Assign Franchise to Order ──────────────────────────────────────────────
  Future<bool> assignFranchise(int orderId, int franchiseId) async {
    try {
      final response = await NetworkApiServices().putApi(
        {'franchise_admin_id': franchiseId},
        '${AppUrls.adminOrdersUrl}/$orderId',
        "Assign Franchise",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        (response['message']?.toString() ?? "Franchise assigned successfully").showToast();
        await fetchOrderDetail(orderId);
        return true;
      } else {
        final msg = response?['message']?.toString() ?? "Failed to assign franchise";
        msg.showToast();
        return false;
      }
    } catch (e) {
      debugPrint('Error assigning franchise: $e');
      "Error assigning franchise".showToast();
      return false;
    }
  }
}

// ── Franchise Item Model ─────────────────────────────────────────────────────

class AdminFranchiseItem {
  final int id;
  final String name;
  final String? location;
  final String? phone;
  final String? email;

  AdminFranchiseItem({
    required this.id,
    required this.name,
    this.location,
    this.phone,
    this.email,
  });

  factory AdminFranchiseItem.fromJson(Map<String, dynamic> json) {
    String name = json['name']?.toString() ??
        json['franchise_name']?.toString() ??
        '';
    if (name.isEmpty) {
      name = '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    }

    return AdminFranchiseItem(
      id: json['id'] ?? 0,
      name: name,
      location: json['location']?.toString() ?? json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }
}
