// ─────────────────────────────────────────────────────────────────────────────
// SERVICE: franchise_tickets_service.dart
// Location: lib/services/Franchise_dashboard_Services/franchise_tickets_service.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/franchise_models/franchise_ticket_model.dart';

class FranchiseTicketsService with ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  FranchiseTicketStatisticsModel? _statistics;
  FranchiseTicketListModel? _ticketList;
  FranchiseTicketDetailModel? _ticketDetail;

  bool _isLoadingStats = false;
  bool _isLoadingList = false;
  bool _isLoadingDetail = false;
  bool _hasListError = false;
  bool _hasDetailError = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  FranchiseTicketStatisticsModel get statistics =>
      _statistics ?? FranchiseTicketStatisticsModel.empty();

  FranchiseTicketListModel get ticketList =>
      _ticketList ?? FranchiseTicketListModel.empty();

  FranchiseTicketDetailModel? get ticketDetail => _ticketDetail;

  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingList => _isLoadingList;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get hasListError => _hasListError;
  bool get hasDetailError => _hasDetailError;

  bool get shouldAutoFetch => _ticketList == null;

  // ── Fetch both stats + list in parallel ────────────────────────────────────
  Future<void> fetchAll({int page = 1}) async {
    if (_isLoadingList) return;

    _isLoadingList = true;
    _hasListError = false;
    notifyListeners();

    try {
      await Future.wait([
        _fetchStatistics(),
        _fetchTickets(page: page),
      ]);
    } catch (e) {
      debugPrint('❌ FranchiseTicketsService.fetchAll: $e');
      _hasListError = true;
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _ticketList = null;
    _statistics = null;
    await fetchAll();
  }

  // ── Fetch ticket detail ────────────────────────────────────────────────────
  Future<void> fetchTicketDetail(int ticketId) async {
    if (_isLoadingDetail) return;

    _isLoadingDetail = true;
    _hasDetailError = false;
    _ticketDetail = null;
    notifyListeners();

    try {
      final url = '${AppUrls.franchiseTicketDetailUrl}/$ticketId';
      final response = await NetworkApiServices().getApi(
        url,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );

      if (response != null) {
        _ticketDetail = FranchiseTicketDetailModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      } else {
        _hasDetailError = true;
      }
    } catch (e) {
      debugPrint('❌ FranchiseTicketsService.fetchTicketDetail: $e');
      _hasDetailError = true;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void clearDetail() {
    _ticketDetail = null;
    _hasDetailError = false;
    notifyListeners();
  }

  // ── Private fetchers ───────────────────────────────────────────────────────
  Future<void> _fetchStatistics() async {
    try {
      final response = await NetworkApiServices().getApi(
        AppUrls.franchiseTicketStatisticsUrl,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );
      if (response != null) {
        _statistics = FranchiseTicketStatisticsModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } catch (e) {
      debugPrint('❌ _fetchStatistics: $e');
      _statistics = FranchiseTicketStatisticsModel.empty();
    }
  }

  Future<void> _fetchTickets({int page = 1}) async {
    try {
      final url = '${AppUrls.franchiseTicketsUrl}?page=$page';
      final response = await NetworkApiServices().getApi(
        url,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );
      if (response != null) {
        _ticketList = FranchiseTicketListModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      } else {
        _hasListError = true;
        _ticketList = FranchiseTicketListModel.empty();
      }
    } catch (e) {
      debugPrint('❌ _fetchTickets: $e');
      _hasListError = true;
      _ticketList = FranchiseTicketListModel.empty();
    }
  }
}