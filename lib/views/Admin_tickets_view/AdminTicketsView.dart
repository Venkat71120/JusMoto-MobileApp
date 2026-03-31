import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminTicketsViewModel.dart';
import 'package:car_service/services/admin_services/AdminTicketsService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminTicketsView extends StatefulWidget {
  const AdminTicketsView({super.key});

  @override
  State<AdminTicketsView> createState() => _AdminTicketsViewState();
}

class _AdminTicketsViewState extends State<AdminTicketsView> {
  late AdminTicketsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminTicketsViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Service Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<AdminTicketsService>(
              builder: (context, service, child) {
                if (service.loading && service.ticketList.tickets.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.ticketList.tickets.isEmpty) {
                  return const Center(child: Text('No service requests found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchTickets(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.ticketList.tickets.length + (service.ticketList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.ticketList.tickets.length) {
                        _viewModel.fetchTickets(page: service.ticketList.pagination.currentPage + 1);
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                      }

                      final ticket = service.ticketList.tickets[index];
                      return _buildTicketCard(ticket);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _viewModel.searchController,
            decoration: InputDecoration(
              hintText: 'Search service requests...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: _viewModel.onSearchChanged,
          ),
          12.toHeight,
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w600)),
              8.toWidth,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _viewModel.statusFilter.isEmpty ? null : _viewModel.statusFilter,
                      hint: const Text('All Statuses'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All Statuses')),
                        DropdownMenuItem(value: 'open', child: Text('Open')),
                        DropdownMenuItem(value: 'closed', child: Text('Closed')),
                      ],
                      onChanged: (val) {
                        _viewModel.onStatusFilterChanged(val);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  child: _buildBadge(ticket.status, _getStatusColor(ticket.status)),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Text('Change Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    ),
                    const PopupMenuItem<String>(
                      value: 'open',
                      child: Text('Mark Open'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'closed',
                      child: Text('Mark Closed'),
                    ),
                  ],
                  onSelected: (val) {
                    _viewModel.updateTicketStatus(ticket.id, val);
                  },
                ),
              ],
            ),
            8.toHeight,
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                4.toWidth,
                Text(ticket.customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.priority_high, size: 14, color: Colors.grey),
                4.toWidth,
                Text(
                  ticket.priority.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getPriorityColor(ticket.priority)),
                ),
              ],
            ),
            12.toHeight,
            Row(
              children: [
                _buildInfoTag(Icons.business, ticket.departmentName),
                12.toWidth,
                _buildInfoTag(Icons.assignment_ind, ticket.assignedTo ?? 'Unassigned'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: #${ticket.id}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
                ),
                Text(
                  ticket.createdAt.split('T')[0],
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          6.toWidth,
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blue;
      case 'closed': return Colors.grey;
      default: return Colors.orange;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
