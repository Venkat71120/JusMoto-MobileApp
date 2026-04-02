import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/admin_ticket_model.dart';
import '../../helper/extension/string_extension.dart';
import '../../services/admin_services/AdminOrdersService.dart';
import '../socket_service.dart';

class AdminTicketsService extends ChangeNotifier {
  AdminTicketListModel _ticketList = AdminTicketListModel.empty();
  AdminTicketListModel get ticketList => _ticketList;

  bool _loading = false;
  bool get loading => _loading;

  // ── Detail State ────────────────────────────────────────────────────────────
  AdminTicketDetailModel? _ticketDetail;
  AdminTicketDetailModel? get ticketDetail => _ticketDetail;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  bool _hasDetailError = false;
  bool get hasDetailError => _hasDetailError;

  // ── Franchise list (reuse from orders service) ─────────────────────────────
  List<AdminFranchiseItem> _franchiseList = [];
  List<AdminFranchiseItem> get franchiseList => _franchiseList;
  bool _isLoadingFranchises = false;
  bool get isLoadingFranchises => _isLoadingFranchises;

  // ── Socket ─────────────────────────────────────────────────────────────────
  SocketService? _socketService;
  int? _activeSocketTicketId;

  // ── Fetch Tickets List ─────────────────────────────────────────────────────

  Future<void> fetchTickets({
    int page = 1,
    String? search,
    String? status,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      String url = '${AppUrls.adminTicketsUrl}?page=$page&limit=15';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (status != null && status.isNotEmpty) url += '&status=$status';

      final response = await NetworkApiServices().getApi(
        url,
        "Admin Tickets List",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        _ticketList = AdminTicketListModel.fromJson(
            Map<String, dynamic>.from(response));
      } else {
        "Failed to load ticket list".showToast();
      }
    } catch (e) {
      debugPrint('Error fetching Admin Tickets: $e');
      "Error: $e".showToast();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Update Ticket Status ───────────────────────────────────────────────────

  Future<bool> updateTicketStatus(int ticketId, String newStatus) async {
    try {
      final response = await NetworkApiServices().putApi(
        {'status': newStatus},
        '${AppUrls.adminTicketsUrl}/$ticketId/status',
        "Update Ticket Status",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        final index =
            _ticketList.tickets.indexWhere((t) => t.id == ticketId);
        if (index != -1) {
          _ticketList.tickets[index] =
              _ticketList.tickets[index].copyWith(status: newStatus);
          notifyListeners();
        }
        "Ticket status updated".showToast();
        return true;
      } else {
        "Failed to update ticket status".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('Error updating ticket status: $e');
      "Error: $e".showToast();
      return false;
    }
  }

  // ── Fetch Ticket Detail ────────────────────────────────────────────────────

  Future<void> fetchTicketDetail(int ticketId, {bool quiet = false}) async {
    if (_isLoadingDetail && !quiet) return;

    _isLoadingDetail = true;
    _hasDetailError = false;
    if (!quiet) _ticketDetail = null;
    notifyListeners();

    try {
      final url = '${AppUrls.adminTicketDetailsUrl}/$ticketId';
      final response = await NetworkApiServices().getApi(
        url,
        null,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );

      if (response != null) {
        debugPrint('Ticket detail keys: ${response.keys}');
        final data = response['data'];
        if (data is Map) {
          debugPrint('Ticket data keys: ${data.keys}');
          debugPrint('franchise_admin_id: ${data['franchise_admin_id']}');
          debugPrint('admin: ${data['admin']}');
          debugPrint('franchise: ${data['franchise']}');
          debugPrint('franchise_admin: ${data['franchise_admin']}');
        }
        _ticketDetail = AdminTicketDetailModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      } else {
        _hasDetailError = true;
      }
    } catch (e) {
      debugPrint('AdminTicketsService.fetchTicketDetail: $e');
      _hasDetailError = true;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ── Update Status from Detail ──────────────────────────────────────────────

  Future<bool> updateTicketStatusFromDetail(
      int ticketId, String newStatus) async {
    final result = await updateTicketStatus(ticketId, newStatus);
    if (result) await fetchTicketDetail(ticketId, quiet: true);
    return result;
  }

  // ── Socket.IO Chat ─────────────────────────────────────────────────────────

  void joinTicketChat(SocketService socket, int ticketId) {
    if (_activeSocketTicketId == ticketId) return;
    leaveTicketChat();

    _socketService = socket;
    _activeSocketTicketId = ticketId;

    debugPrint('Joining Socket.IO chat for ticket #$ticketId');
    _socketService!.subscribe('ticket-message-$ticketId', _onMessageReceived);
    _socketService!.subscribe('message', _onMessageReceived);
  }

  void leaveTicketChat() {
    if (_socketService != null && _activeSocketTicketId != null) {
      _socketService!.unsubscribe('ticket-message-$_activeSocketTicketId');
      _socketService!.unsubscribe('message');
      _activeSocketTicketId = null;
    }
  }

  void _onMessageReceived(dynamic data) {
    debugPrint('Socket Message Received: $data');
    if (_ticketDetail == null) return;

    try {
      final messageData = data is String
          ? Map<String, dynamic>.from(jsonDecode(data))
          : Map<String, dynamic>.from(data);

      if (messageData.containsKey('ticket_id')) {
        final tId = int.tryParse(messageData['ticket_id'].toString());
        if (tId != _activeSocketTicketId) return;
      }

      final newMessage = AdminTicketMessage.fromJson(messageData);

      if (_ticketDetail!.messages
          .any((m) => m.id == newMessage.id && m.id != 0)) {
        return;
      }

      _ticketDetail!.messages.insert(0, newMessage);
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing socket message: $e');
    }
  }

  // ── Send Reply ─────────────────────────────────────────────────────────────

  Future<bool> sendReply(int ticketId,
      {required String message, String? filePath}) async {
    try {
      final url = '${AppUrls.adminTicketsUrl}/$ticketId/reply';
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
        request.fields['message'] = message.trim().isEmpty ? 'Attachment' : message;

        String ext = filePath.split('.').last.toLowerCase();
        MediaType? mediaType;
        if (['jpg', 'jpeg'].contains(ext)) {
          mediaType = MediaType('image', 'jpeg');
        } else if (ext == 'png') {
          mediaType = MediaType('image', 'png');
        } else if (ext == 'gif') {
          mediaType = MediaType('image', 'gif');
        } else if (ext == 'webp') {
          mediaType = MediaType('image', 'webp');
        } else if (ext == 'pdf') {
          mediaType = MediaType('application', 'pdf');
        } else if (ext == 'doc') {
          mediaType = MediaType('application', 'msword');
        } else if (ext == 'docx') {
          mediaType = MediaType('application',
              'vnd.openxmlformats-officedocument.wordprocessingml.document');
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            filePath,
            contentType: mediaType,
          ),
        );

        debugPrint('Sending file upload: ${request.url}');
        debugPrint('Fields: ${request.fields}');
        debugPrint('Files: ${request.files.map((f) => '${f.field}: ${f.filename} (${f.contentType})').toList()}');

        response = await NetworkApiServices().postWithFileApi(
          request,
          'sendAdminTicketReply',
          headers: acceptJsonAuthHeader,
        );
      }

      if (response != null && response['success'] == true) {
        await fetchTicketDetail(ticketId, quiet: true);
        return true;
      }
    } catch (e) {
      debugPrint('sendReply: $e');
    }
    return false;
  }

  // ── Fetch Franchise List ───────────────────────────────────────────────────

  Future<void> fetchFranchiseList() async {
    if (_isLoadingFranchises) return;
    _isLoadingFranchises = true;
    notifyListeners();

    try {
      final response = await NetworkApiServices().getApi(
        '${AppUrls.adminFranchisesUrl}?limit=100',
        null,
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        final list = response['data'] as List? ?? [];
        _franchiseList = list
            .map((f) => AdminFranchiseItem.fromJson(
                Map<String, dynamic>.from(f)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching franchises: $e');
    } finally {
      _isLoadingFranchises = false;
      notifyListeners();
    }
  }

  // ── Assign Franchise ───────────────────────────────────────────────────────

  Future<bool> assignFranchise(int ticketId, int franchiseId) async {
    try {
      final response = await NetworkApiServices().putApi(
        {'franchise_admin_id': franchiseId},
        '${AppUrls.adminTicketsUrl}/$ticketId',
        "Assign Franchise",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        (response['message']?.toString() ?? "Franchise assigned").showToast();
        await fetchTicketDetail(ticketId, quiet: true);
        return true;
      } else {
        "Failed to assign franchise".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('Error assigning franchise: $e');
      "Error assigning franchise".showToast();
      return false;
    }
  }

  void clearDetail() {
    _ticketDetail = null;
    _hasDetailError = false;
    leaveTicketChat();
    notifyListeners();
  }
}
