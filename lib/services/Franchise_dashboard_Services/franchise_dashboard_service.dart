// ─────────────────────────────────────────────────────────────────────────────
// SERVICE: franchise_dashboard_service.dart
// Location: lib/services/Franchise_dashboard_Services/franchise_dashboard_service.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/franchise_models/franchise_dashboard_model.dart';

class FranchiseDashboardService with ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  FranchiseDashboardStatisticsModel? _statistics;
  FranchiseOrderCountsModel? _orderCounts;
  FranchiseEarningsModel? _earnings;
  FranchiseRecentActivityModel? _recentActivity;

  bool _isLoading = false;
  bool _hasError = false;

  // ── Public getters ─────────────────────────────────────────────────────────
  FranchiseDashboardStatisticsModel get statistics =>
      _statistics ?? FranchiseDashboardStatisticsModel.empty();

  FranchiseOrderCountsModel get orderCounts =>
      _orderCounts ?? FranchiseOrderCountsModel.empty();

  FranchiseEarningsModel get earnings =>
      _earnings ?? FranchiseEarningsModel.empty();

  FranchiseRecentActivityModel get recentActivity =>
      _recentActivity ?? FranchiseRecentActivityModel.empty();

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  bool get shouldAutoFetch =>
      _statistics == null &&
      _orderCounts == null &&
      _earnings == null &&
      _recentActivity == null;

  // ── Fetch consolidated dashboard data ────────────────────────────────────
  Future<void> fetchDashboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // ── Concurrent fetching ────────────────────────────────────────────────
      final results = await Future.wait([
        NetworkApiServices().getApi(
          AppUrls.franchiseDashboardUrl,
          null,
          headers: acceptJsonAuthHeader,
          timeoutSeconds: 20,
        ),
        _fetchEarningsPeriodic(),
        _fetchRecentActivity(),
        _fetchOrderCounts(),
      ]);

      final dashboardResponse = results[0] as Map<String, dynamic>?;
      // results[1] is result of _fetchEarningsPeriodic (bool)
      // results[2] is result of _fetchRecentActivity (bool)

      if (dashboardResponse != null && dashboardResponse['success'] == true) {
        final data = dashboardResponse['data'] as Map<String, dynamic>;
        debugPrint('📊 FranchiseDashboardService.fetchDashboard data: $data');

        // 1. Map to Statistics (Orders, Tickets, Earnings - initially from consolidated)
        _statistics = FranchiseDashboardStatisticsModel.fromJson(data);

        // 2. Map to Order Counts (for breakdown section) - only if dedicated fetch didn't set it
        if (_orderCounts == null || _orderCounts!.total == 0) {
          _orderCounts = FranchiseOrderCountsModel.fromJson(data);
        }

        // 3. Map to Earnings model (consolidated)
        _earnings = FranchiseEarningsModel.fromJson(data);

        // 4. Overwrite periodic earnings stats if fetchEarningsPeriodic succeeded
        if (_tempEarningStats != null) {
          _statistics = FranchiseDashboardStatisticsModel(
            orders: _statistics!.orders,
            tickets: _statistics!.tickets,
            earnings: _tempEarningStats!,
          );
          
          // Also update the detailed earnings model if needed
          _earnings = FranchiseEarningsModel(
            period: 'all',
            totalEarnings: _tempEarningStats!.total,
            totalTax: 0,
            netEarnings: _tempEarningStats!.netTotal,
            orderCount: _statistics!.orders.total,
            averageOrderValue: _statistics!.orders.total > 0
                ? _tempEarningStats!.total / _statistics!.orders.total
                : 0,
          );
        }

        _hasError = false;
      } else {
        _hasError = true;
      }
    } catch (e) {
      debugPrint('❌ FranchiseDashboardService.fetchDashboard error: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  EarningStats? _tempEarningStats;

  Future<bool> _fetchEarningsPeriodic() async {
    try {
      final response = await NetworkApiServices().getApi(
        AppUrls.franchiseDashboardEarningsUrl,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );
      if (response != null && response['success'] == true) {
        _tempEarningStats = EarningStats.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
        return true;
      }
    } catch (e) {
      debugPrint('❌ _fetchEarningsPeriodic: $e');
    }
    return false;
  }

  Future<bool> _fetchOrderCounts() async {
    try {
      final response = await NetworkApiServices().getApi(
        AppUrls.franchiseDashboardOrderCountsUrl,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );
      if (response != null && response['success'] == true) {
        _orderCounts = FranchiseOrderCountsModel.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
        return true;
      }
    } catch (e) {
      debugPrint('❌ _fetchOrderCounts: $e');
    }
    return false;
  }


  /// Pull-to-refresh — forces a re-fetch even if data exists
  Future<void> refresh() async {
    _statistics = null;
    _orderCounts = null;
    _earnings = null;
    _recentActivity = null;
    await fetchDashboard();
  }



  Future<bool> _fetchRecentActivity() async {
    try {
      final response = await NetworkApiServices().getApi(
        AppUrls.franchiseDashboardRecentActivityUrl,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );
      if (response != null) {
        debugPrint('📊 FranchiseDashboardService._fetchRecentActivity response: $response');
        _recentActivity = FranchiseRecentActivityModel.fromJson(
          Map<String, dynamic>.from(response),
        );
        return true;
      }
    } catch (e) {
      debugPrint('❌ _fetchRecentActivity: $e');
    }
    _recentActivity = FranchiseRecentActivityModel.empty();
    return false;
  }
}