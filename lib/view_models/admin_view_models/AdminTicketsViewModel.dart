import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminTicketsService.dart';

class AdminTicketsViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminTicketsViewModel(this.context);

  final TextEditingController searchController = TextEditingController();
  String _statusFilter = ''; // open, closed
  String get statusFilter => _statusFilter;

  Timer? _searchTimer;

  void init() {
    fetchTickets();
  }

  void fetchTickets({int page = 1}) {
    final service = Provider.of<AdminTicketsService>(context, listen: false);
    service.fetchTickets(
      page: page,
      search: searchController.text,
      status: _statusFilter,
    );
  }

  void onStatusFilterChanged(String? value) {
    _statusFilter = value ?? '';
    notifyListeners();
    fetchTickets();
  }

  void onSearchChanged(String value) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchTickets();
    });
  }

  Future<void> updateTicketStatus(int ticketId, String newStatus) async {
    final service = Provider.of<AdminTicketsService>(context, listen: false);
    final success = await service.updateTicketStatus(ticketId, newStatus);
    if (success) {
      // Background fetch to ensure everything is in sync after local update
      fetchTickets(page: service.ticketList.pagination.currentPage);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }
}
