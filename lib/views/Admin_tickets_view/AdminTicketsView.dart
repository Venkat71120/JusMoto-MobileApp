import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminTicketsViewModel.dart';
import 'package:car_service/services/admin_services/AdminTicketsService.dart';
import 'package:car_service/views/Admin_tickets_view/AdminTicketDetailView.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.init());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: Text('Service Requests',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: context.color.primaryContrastColor)),
        elevation: 0,
        backgroundColor: context.color.accentContrastColor,
        surfaceTintColor: context.color.accentContrastColor,
      ),
      body: Column(
        children: [
          // ── Search & Filter ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            color: context.color.accentContrastColor,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.color.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _viewModel.searchController,
                      style: context.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Search tickets...',
                        hintStyle: context.bodySmall?.copyWith(
                            color: context.color.tertiaryContrastColo),
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 20,
                            color: context.color.tertiaryContrastColo),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: _viewModel.onSearchChanged,
                      onSubmitted: (_) => _viewModel.fetchTickets(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: context.color.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _viewModel.statusFilter.isEmpty
                            ? null
                            : _viewModel.statusFilter,
                        hint: Text('Status',
                            style: context.bodySmall?.copyWith(
                                color: context.color.tertiaryContrastColo)),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: context.color.tertiaryContrastColo),
                        style: context.bodySmall?.copyWith(
                            color: context.color.primaryContrastColor),
                        items: [
                          DropdownMenuItem(
                              value: '',
                              child:
                                  Text('All', style: context.bodySmall)),
                          DropdownMenuItem(
                              value: 'open',
                              child:
                                  Text('Open', style: context.bodySmall)),
                          DropdownMenuItem(
                              value: 'closed',
                              child: Text('Closed',
                                  style: context.bodySmall)),
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
          ),

          // ── Ticket List ────────────────────────────────────────────
          Expanded(
            child: Consumer<AdminTicketsService>(
              builder: (context, service, _) {
                if (service.loading &&
                    service.ticketList.tickets.isEmpty) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: primaryColor));
                }

                if (service.ticketList.tickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.support_agent_rounded,
                            size: 56,
                            color: context.color.tertiaryContrastColo),
                        12.toHeight,
                        Text('No service requests found',
                            style: context.bodyMedium?.copyWith(
                                color:
                                    context.color.tertiaryContrastColo)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () async => _viewModel.fetchTickets(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: service.ticketList.tickets.length +
                        (service.ticketList.pagination.hasNextPage
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index == service.ticketList.tickets.length) {
                        _viewModel.fetchTickets(
                            page: service.ticketList.pagination
                                    .currentPage +
                                1);
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor, strokeWidth: 2)),
                        );
                      }
                      final ticket = service.ticketList.tickets[index];
                      return _TicketCard(
                        ticket: ticket,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminTicketDetailView(
                                ticketId: ticket.id),
                          ),
                        ),
                        onStatusChange: (status) =>
                            _viewModel.updateTicketStatus(
                                ticket.id, status),
                      );
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

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TICKET CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final dynamic ticket;
  final VoidCallback onTap;
  final Function(String) onStatusChange;

  const _TicketCard({
    required this.ticket,
    required this.onTap,
    required this.onStatusChange,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.green;
      case 'in_progress': return Colors.orange;
      case 'closed': return Colors.grey;
      default: return Colors.blue;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.amber.shade700;
      case 'normal': return Colors.blue;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sColor = _statusColor(ticket.status);
    final pColor = _priorityColor(ticket.priority);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top section ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: pColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.flag_rounded,
                        size: 18, color: pColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          style: context.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.toHeight,
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 13,
                                color:
                                    context.color.tertiaryContrastColo),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ticket.customerName,
                                style: context.bodySmall?.copyWith(
                                    color: context
                                        .color.secondaryContrastColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '#${ticket.id}',
                        style: context.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: primaryColor),
                      ),
                      4.toHeight,
                      Text(
                        ticket.createdAt.split('T')[0],
                        style: context.bodySmall?.copyWith(
                            color: context.color.tertiaryContrastColo,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Bottom section ───────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    context.color.mutedContrastColor.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  _Chip(label: ticket.status.toUpperCase(), color: sColor),
                  const SizedBox(width: 8),
                  _Chip(
                      label: ticket.priority.toUpperCase(),
                      color: pColor),
                  if (ticket.departmentName != 'N/A') ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: _Chip(
                          label: ticket.departmentName,
                          color: context.color.tertiaryContrastColo),
                    ),
                  ],
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz_rounded,
                        size: 20,
                        color: context.color.tertiaryContrastColo),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          enabled: false,
                          child: Text('Change Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12))),
                      const PopupMenuItem(
                          value: 'open',
                          child: Text('Open',
                              style: TextStyle(fontSize: 13))),
                      const PopupMenuItem(
                          value: 'in_progress',
                          child: Text('In Progress',
                              style: TextStyle(fontSize: 13))),
                      const PopupMenuItem(
                          value: 'closed',
                          child: Text('Closed',
                              style: TextStyle(fontSize: 13))),
                    ],
                    onSelected: onStatusChange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
