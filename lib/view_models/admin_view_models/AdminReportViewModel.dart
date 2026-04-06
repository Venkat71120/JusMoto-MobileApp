import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminReportService.dart';
import 'package:intl/intl.dart';

class AdminReportViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminReportViewModel(this.context);

  String _fromDate = '';
  String _toDate = '';
  String _groupBy = 'day';

  String get fromDate => _fromDate;
  String get toDate => _toDate;
  String get groupBy => _groupBy;

  void init() {
    final now = DateTime.now();
    _toDate = DateFormat('yyyy-MM-dd').format(now);
    _fromDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    fetchRevenue();
    fetchOrders();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    if (from != null) _fromDate = DateFormat('yyyy-MM-dd').format(from);
    if (to != null) _toDate = DateFormat('yyyy-MM-dd').format(to);
    fetchRevenue();
    notifyListeners();
  }

  void setGroupBy(String val) {
    _groupBy = val;
    fetchRevenue();
    notifyListeners();
  }

  void fetchRevenue() {
    final service = Provider.of<AdminReportService>(context, listen: false);
    service.fetchRevenueReport(from: _fromDate, to: _toDate, groupBy: _groupBy);
  }

  void fetchOrders() {
    final service = Provider.of<AdminReportService>(context, listen: false);
    service.fetchOrderReport();
  }
}
