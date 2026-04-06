import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/AdminReportModels.dart';

class AdminReportService extends ChangeNotifier {
  AdminRevenueReportListModel _revenueReport = AdminRevenueReportListModel.empty();
  AdminRevenueReportListModel get revenueReport => _revenueReport;

  AdminOrderReportListModel _orderReport = AdminOrderReportListModel.empty();
  AdminOrderReportListModel get orderReport => _orderReport;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchRevenueReport({String? from, String? to, String groupBy = 'day'}) async {
    _loading = true;
    notifyListeners();
    try {
      String url = '${AppUrls.adminReportsRevenueUrl}?group_by=$groupBy';
      if (from != null && from.isNotEmpty) url += '&from=$from';
      if (to != null && to.isNotEmpty) url += '&to=$to';

      final response = await NetworkApiServices().getApi(url, "Admin Revenue Report", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _revenueReport = AdminRevenueReportListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching revenue report: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderReport() async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().getApi(AppUrls.adminReportsOrdersUrl, "Admin Orders Report", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _orderReport = AdminOrderReportListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching order report: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
