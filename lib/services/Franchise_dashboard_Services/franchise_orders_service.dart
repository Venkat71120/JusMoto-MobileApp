// ─────────────────────────────────────────────────────────────────────────────
// SERVICE: franchise_orders_service.dart
// Location: lib/services/Franchise_dashboard_Services/franchise_orders_service.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/franchise_models/franchise_order_model.dart';

class FranchiseOrdersService with ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  FranchiseOrderListModel? _orderList;
  FranchiseOrderDetailModel? _orderDetail;

  bool _isLoadingList = false;
  bool _isLoadingDetail = false;
  bool _hasListError = false;
  bool _hasDetailError = false;

  // ── Public Getters ─────────────────────────────────────────────────────────
  FranchiseOrderListModel get orderList =>
      _orderList ?? FranchiseOrderListModel.empty();

  FranchiseOrderDetailModel? get orderDetail => _orderDetail;

  bool get isLoadingList => _isLoadingList;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get hasListError => _hasListError;
  bool get hasDetailError => _hasDetailError;

  bool get shouldAutoFetch => _orderList == null;

  // ── Fetch Orders List ──────────────────────────────────────────────────────
  Future<void> fetchOrders({int page = 1}) async {
    if (_isLoadingList) return;

    _isLoadingList = true;
    _hasListError = false;
    notifyListeners();

    try {
      final url = '${AppUrls.franchiseOrdersUrl}?page=$page';
      final response = await NetworkApiServices().getApi(
        url,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );

      if (response != null) {
        _orderList = FranchiseOrderListModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      } else {
        _hasListError = true;
        _orderList = FranchiseOrderListModel.empty();
      }
    } catch (e) {
      debugPrint('❌ FranchiseOrdersService.fetchOrders: $e');
      _hasListError = true;
      _orderList = FranchiseOrderListModel.empty();
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh
  Future<void> refreshOrders() async {
    _orderList = null;
    await fetchOrders();
  }

  // ── Fetch Order Detail ─────────────────────────────────────────────────────
  Future<void> fetchOrderDetail(int orderId) async {
    if (_isLoadingDetail) return;

    _isLoadingDetail = true;
    _hasDetailError = false;
    _orderDetail = null;
    notifyListeners();

    try {
      final url = '${AppUrls.franchiseOrderDetailUrl}/$orderId';
      final response = await NetworkApiServices().getApi(
        url,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );

      if (response != null) {
        _orderDetail = FranchiseOrderDetailModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      } else {
        _hasDetailError = true;
      }
    } catch (e) {
      debugPrint('❌ FranchiseOrdersService.fetchOrderDetail: $e');
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
}