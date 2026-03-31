import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminOrdersService.dart';

class AdminOrdersViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminOrdersViewModel(this.context);

  final TextEditingController searchController = TextEditingController();
  String _statusFilter = ''; // Status code: 0-4
  String get statusFilter => _statusFilter;

  String _paymentFilter = ''; // 1=Paid, 0=Unpaid
  String get paymentFilter => _paymentFilter;

  Timer? _searchTimer;

  final List<Map<String, String>> statusTabs = [
    {'label': 'All', 'value': ''},
    {'label': 'Pending', 'value': '0'},
    {'label': 'Accepted', 'value': '1'},
    {'label': 'In Progress', 'value': '2'},
    {'label': 'Completed', 'value': '3'},
    {'label': 'Cancelled', 'value': '4'},
  ];

  void init() {
    fetchOrders();
  }

  void fetchOrders({int page = 1}) {
    final service = Provider.of<AdminOrdersService>(context, listen: false);
    service.fetchOrders(
      page: page,
      search: searchController.text,
      status: _statusFilter,
      paymentStatus: _paymentFilter,
    );
  }

  void onStatusTabChanged(String value) {
    _statusFilter = value;
    notifyListeners();
    fetchOrders();
  }

  void onPaymentFilterChanged(String? value) {
    _paymentFilter = value ?? '';
    notifyListeners();
    fetchOrders();
  }

  void onSearchChanged(String value) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchOrders();
    });
  }

  Future<void> updateOrderStatus(int orderId, int newStatus) async {
    final service = Provider.of<AdminOrdersService>(context, listen: false);
    final success = await service.updateOrderStatus(orderId, newStatus);
    if (success) {
      fetchOrders(page: service.orderList.pagination.currentPage);
    }
  }

  Future<void> updatePaymentStatus(int orderId, int currentStatus) async {
    final service = Provider.of<AdminOrdersService>(context, listen: false);
    final success = await service.updatePaymentStatus(orderId, currentStatus == 1 ? 0 : 1);
    if (success) {
      fetchOrders(page: service.orderList.pagination.currentPage);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }
}
