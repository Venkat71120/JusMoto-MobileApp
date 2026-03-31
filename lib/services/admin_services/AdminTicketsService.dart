import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/admin_ticket_model.dart';
import '../../helper/extension/string_extension.dart';

class AdminTicketsService extends ChangeNotifier {
  AdminTicketListModel _ticketList = AdminTicketListModel.empty();
  AdminTicketListModel get ticketList => _ticketList;

  bool _loading = false;
  bool get loading => _loading;

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
        _ticketList = AdminTicketListModel.fromJson(Map<String, dynamic>.from(response));
        debugPrint('✅ Admin Tickets fetched successfully');
      } else {
        debugPrint('❌ Failed to fetch Admin Tickets');
        "Failed to load ticket list".showToast();
      }
    } catch (e) {
      debugPrint('❌ Exception fetching Admin Tickets: $e');
      "Error: $e".showToast();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTicketStatus(int ticketId, String newStatus) async {
    try {
      final response = await NetworkApiServices().putApi(
        {'status': newStatus},
        '${AppUrls.adminTicketsUrl}/$ticketId/status',
        "Update Ticket Status",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        // Update local state for immediate feedback
        final index = _ticketList.tickets.indexWhere((t) => t.id == ticketId);
        if (index != -1) {
          _ticketList.tickets[index] = _ticketList.tickets[index].copyWith(status: newStatus);
          notifyListeners();
        }
        "Ticket status updated".showToast();
        return true;
      } else {
        "Failed to update ticket status".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating ticket status: $e');
      "Error: $e".showToast();
      return false;
    }
  }
}
