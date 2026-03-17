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

  String? _dateFrom;
  String? _dateTo;

  // ── Public Getters ─────────────────────────────────────────────────────────
  FranchiseOrderListModel get orderList =>
      _orderList ?? FranchiseOrderListModel.empty();

  FranchiseOrderDetailModel? get orderDetail => _orderDetail;

  bool get isLoadingList => _isLoadingList;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get hasListError => _hasListError;
  bool get hasDetailError => _hasDetailError;

  String? get dateFrom => _dateFrom;
  String? get dateTo => _dateTo;

  void setFilters({String? from, String? to}) {
    _dateFrom = from;
    _dateTo = to;
    notifyListeners();
  }

  void clearFilters() {
    _dateFrom = null;
    _dateTo = null;
    notifyListeners();
  }

  bool get shouldAutoFetch => _orderList == null;

  // ── Fetch Orders List ──────────────────────────────────────────────────────
  Future<void> fetchOrders({int page = 1}) async {
    if (_isLoadingList) return;

    _isLoadingList = true;
    _hasListError = false;
    notifyListeners();

    try {
      String query = 'page=$page';
      if (_dateFrom != null && _dateFrom!.isNotEmpty) {
        query += '&date_from=$_dateFrom';
      }
      if (_dateTo != null && _dateTo!.isNotEmpty) {
        query += '&date_to=$_dateTo';
      }

      final url = '${AppUrls.franchiseOrdersUrl}?$query';
      final response = await NetworkApiServices().getApi(
        url,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );

      if (response != null && response['success'] == true) {
        final newModel = FranchiseOrderListModel.fromJson(
          Map<String, dynamic>.from(response),
        );

        if (page == 1) {
          _orderList = newModel;
        } else {
          // Append to existing list
          final currentOrders = _orderList?.orders ?? [];
          final updatedOrders = [...currentOrders, ...newModel.orders];
          _orderList = FranchiseOrderListModel(
            orders: updatedOrders,
            pagination: newModel.pagination,
          );
        }
        _hasListError = false;
      } else {
        _hasListError = true;
        if (page == 1) _orderList = FranchiseOrderListModel.empty();
      }
    } catch (e) {
      debugPrint('❌ FranchiseOrdersService.fetchOrders: $e');
      _hasListError = true;
      if (page == 1) _orderList = FranchiseOrderListModel.empty();
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