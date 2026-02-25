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

  // ── Fetch all 4 endpoints in parallel ─────────────────────────────────────
  Future<void> fetchDashboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final results = await Future.wait([
        _fetchStatistics(),
        _fetchOrderCounts(),
        _fetchEarnings(),
        _fetchRecentActivity(),
      ]);

      _hasError = results.contains(false);
    } catch (e) {
      debugPrint('❌ FranchiseDashboardService.fetchDashboard error: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh — forces a re-fetch even if data exists
  Future<void> refresh() async {
    _statistics = null;
    _orderCounts = null;
    _earnings = null;
    _recentActivity = null;
    await fetchDashboard();
  }

  // ── Private per-endpoint fetchers ──────────────────────────────────────────
  Future<bool> _fetchStatistics() async {
    try {
      final response = await NetworkApiServices().getApi(
        AppUrls.franchiseDashboardStatisticsUrl,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );
      if (response != null) {
        _statistics = FranchiseDashboardStatisticsModel.fromJson(
          Map<String, dynamic>.from(response),
        );
        return true;
      }
    } catch (e) {
      debugPrint('❌ _fetchStatistics: $e');
    }
    _statistics = FranchiseDashboardStatisticsModel.empty();
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
      if (response != null) {
        _orderCounts = FranchiseOrderCountsModel.fromJson(
          Map<String, dynamic>.from(response),
        );
        return true;
      }
    } catch (e) {
      debugPrint('❌ _fetchOrderCounts: $e');
    }
    _orderCounts = FranchiseOrderCountsModel.empty();
    return false;
  }

  Future<bool> _fetchEarnings() async {
    try {
      final response = await NetworkApiServices().getApi(
        AppUrls.franchiseDashboardEarningsUrl,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );
      if (response != null) {
        _earnings = FranchiseEarningsModel.fromJson(
          Map<String, dynamic>.from(response),
        );
        return true;
      }
    } catch (e) {
      debugPrint('❌ _fetchEarnings: $e');
    }
    _earnings = FranchiseEarningsModel.empty();
    return false;
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