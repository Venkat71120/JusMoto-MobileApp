import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../models/admin_models/admin_dashboard_model.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';




class AdminDashboardService extends ChangeNotifier {
  AdminDashboardModel _dashboardData = AdminDashboardModel.empty();
  AdminDashboardModel get dashboardData => _dashboardData;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchDashboardData() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await NetworkApiServices().getApi(
        AppUrls.adminDashboardUrl,
        "Admin Dashboard",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        _dashboardData = AdminDashboardModel.fromJson(Map<String, dynamic>.from(response['data'] ?? {}));
        debugPrint('✅ Admin Dashboard data fetched successfully');
      } else {
        debugPrint('❌ Failed to fetch Admin Dashboard data');
        "Failed to load dashboard data".showToast();
      }
    } catch (e) {
      debugPrint('❌ Exception fetching Admin Dashboard data: $e');
      "Error: $e".showToast();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
