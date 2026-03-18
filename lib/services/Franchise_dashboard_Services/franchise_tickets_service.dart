// ─────────────────────────────────────────────────────────────────────────────
// SERVICE: franchise_tickets_service.dart
// Location: lib/services/Franchise_dashboard_Services/franchise_tickets_service.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/franchise_models/franchise_ticket_model.dart';
import '../socket_service.dart';

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

  String? _dateFrom;
  String? _dateTo;

  SocketService? _socketService;
  int? _activeSocketTicketId;

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

      if (response != null && response['success'] == true) {
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

  // ── Socket.IO Integration ──────────────────────────────────────────────────

  void joinTicketChat(SocketService socket, int ticketId) {
    if (_activeSocketTicketId == ticketId) return;

    // Leave previous channel if any
    leaveTicketChat();

    _socketService = socket;
    _activeSocketTicketId = ticketId;

    debugPrint('🔌 Joining Socket.IO chat for ticket #$ticketId');
    
    // Listen for new messages. 
    // Expecting event name like: 'ticket-message-received' or common 'message'
    _socketService!.subscribe('ticket-message-$ticketId', _onMessageReceived);
    _socketService!.subscribe('message', _onMessageReceived);
  }

  void leaveTicketChat() {
    if (_socketService != null && _activeSocketTicketId != null) {
      debugPrint('🔌 Leaving Socket.IO chat for ticket #$_activeSocketTicketId');
      _socketService!.unsubscribe('ticket-message-$_activeSocketTicketId');
      _socketService!.unsubscribe('message');
      _activeSocketTicketId = null;
    }
  }

  void _onMessageReceived(dynamic data) {
    debugPrint('📩 Socket Message Received: $data');
    if (_ticketDetail == null) return;

    try {
      final messageData = data is String ? Map<String, dynamic>.from(jsonDecode(data)) : Map<String, dynamic>.from(data);
      
      // Ensure it belongs to the current ticket (if data includes ticket_id)
      if (messageData.containsKey('ticket_id')) {
          final tId = int.tryParse(messageData['ticket_id'].toString());
          if (tId != _activeSocketTicketId) return;
      }

      final newMessage = FranchiseTicketMessage.fromJson(messageData);
      
      // Prevent duplicates if already fetched via API
      if (_ticketDetail!.messages.any((m) => m.id == newMessage.id && m.id != 0)) {
        return;
      }

      _ticketDetail!.messages.insert(0, newMessage);
      notifyListeners();
      debugPrint('✅ New message appended to UI');
    } catch (e) {
      debugPrint('❌ Error parsing socket message: $e');
    }
  }

  // ── Update service request status ───────────────────────────────────────────
  Future<bool> updateServiceRequestStatus(int id, String status) async {
    try {
      final url = '${AppUrls.franchiseTicketsUrl}/$id/status';
      final response = await NetworkApiServices().putApi(
        {'status': status},
        url,
        null,
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        // ── Refresh stats + list after success ──────────────────────────
        await Future.wait([
          _fetchStatistics(),
          _fetchTickets(page: 1),
        ]);

        // Refresh detail if currently open
        if (_ticketDetail?.ticket.id == id) {
          await fetchTicketDetail(id);
        }
        return true;
      }
    } catch (e) {
      debugPrint('❌ updateServiceRequestStatus: $e');
    }
    return false;
  }

  // ── Send service request reply ─────────────────────────────────────────────
  Future<bool> sendServiceRequestReply(int id, {required String message, String? filePath}) async {
    try {
      final url = '${AppUrls.franchiseTicketsUrl}/$id/reply';
      Map? response;

      if (filePath == null) {
        response = await NetworkApiServices().postApi(
          {'message': message},
          url,
          null,
          headers: acceptJsonAuthHeader,
        );
      } else {
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll(acceptJsonAuthHeader);
        request.fields['message'] = message;
        request.files.add(await http.MultipartFile.fromPath('attachment', filePath));

        response = await NetworkApiServices().postWithFileApi(
          request,
          'sendServiceRequestReplyWithFile',
          headers: acceptJsonAuthHeader,
        );
      }

      if (response != null && response['success'] == true) {
        // Refresh detail to show new message
        await fetchTicketDetail(id);
        return true;
      }
    } catch (e) {
      debugPrint('❌ sendServiceRequestReply: $e');
    }
    return false;
  }

  void clearDetail() {
    _ticketDetail = null;
    _hasDetailError = false;
    notifyListeners();
  }

  // ── Private fetchers ───────────────────────────────────────────────────────
  Future<void> _fetchStatistics() async {
    try {
      final url = '${AppUrls.franchiseTicketStatisticsUrl}';
      final response = await NetworkApiServices().getApi(url, null, headers: acceptJsonAuthHeader);
      
      if (response != null && response['success'] == true) {
        _statistics = FranchiseTicketStatisticsModel.fromJson(Map<String, dynamic>.from(response));
      } else {
        // Fallback: manual count from list if API fails or doesn't provide what we need
        int open = 0, closed = 0, inProgress = 0, total = 0;
        for (var ticket in _ticketList?.tickets ?? []) {
          total++;
          final status = ticket.status.toLowerCase();
          if (status == 'open' || status == '1') {
            open++;
          } else if (status == 'closed' || status == 'close' || status == '2') {
            closed++;
          } else if (status == 'in_progress' || status == 'in-progress' || status == '3') {
            inProgress++;
          }
        }
        _statistics = FranchiseTicketStatisticsModel(
          open: open,
          closed: closed,
          inProgress: inProgress,
          total: total,
        );
      }
    } catch (e) {
      debugPrint('❌ _fetchStatistics: $e');
      _statistics = FranchiseTicketStatisticsModel.empty();
    }
  }

  Future<void> _fetchTickets({int page = 1}) async {
    try {
      String query = 'page=$page';
      if (_dateFrom != null && _dateFrom!.isNotEmpty) {
        query += '&date_from=$_dateFrom';
      }
      if (_dateTo != null && _dateTo!.isNotEmpty) {
        // ✅ FIX: Inclusive same-day filter
        final toParam = _dateTo!.length == 10 ? '$_dateTo 23:59:59' : _dateTo;
        query += '&date_to=$toParam';
      }

      final url = '${AppUrls.franchiseTicketsUrl}?$query';
      final response = await NetworkApiServices().getApi(
        url,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );
      if (response != null && response['success'] == true) {
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