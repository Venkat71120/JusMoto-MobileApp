// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT: franchise_activity_section.dart
// Location: lib/views/Franchise_home_view/components/franchise_activity_section.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/franchise_models/franchise_dashboard_model.dart';
import 'package:car_service/view_models/franchise_home_view_model/franchise_home_view_model.dart';
import 'package:flutter/material.dart';

class FranchiseActivitySection extends StatelessWidget {
  final FranchiseRecentActivityModel activity;
  final FranchiseHomeViewModel hvm;

  const FranchiseActivitySection({
    super.key,
    required this.activity,
    required this.hvm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('Recent Activity', style: context.titleMedium?.bold),
            ),
            12.toHeight,

            // ── Tab strip ──────────────────────────────────────────────────
            ValueListenableBuilder<int>(
              valueListenable: hvm.activityTab,
              builder: (context, tab, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _TabChip(
                        label: 'Orders (${activity.orders.length})',
                        isSelected: tab == 0,
                        onTap: () => hvm.activityTab.value = 0,
                      ),
                      12.toWidth,
                      _TabChip(
                        label: 'Tickets (${activity.tickets.length})',
                        isSelected: tab == 1,
                        onTap: () => hvm.activityTab.value = 1,
                      ),
                    ],
                  ),
                );
              },
            ),
            12.toHeight,

            // ── Tabbed content ─────────────────────────────────────────────
            ValueListenableBuilder<int>(
              valueListenable: hvm.activityTab,
              builder: (context, tab, _) {
                if (tab == 0) {
                  return _OrdersList(orders: activity.orders);
                }
                return _TicketsList(tickets: activity.tickets);
              },
            ),

            16.toHeight,
          ],
        ),
      ),
    );
  }
}

// ── Tab Chip ──────────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : primaryColor,
          ),
        ),
      ),
    );
  }
}

// ── Orders List ───────────────────────────────────────────────────────────────

class _OrdersList extends StatelessWidget {
  final List<RecentOrder> orders;
  const _OrdersList({required this.orders});

  Color _statusColor(int code) {
    switch (code) {
      case 0: return Colors.orange;
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.teal;
      case 4: return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No recent orders',
            style: context.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Colors.grey.withOpacity(0.15),
      ),
      itemBuilder: (context, i) {
        final order = orders[i];
        final statusColor = _statusColor(order.statusCode);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Status indicator dot
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 12, top: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              // Invoice + customer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.invoiceNumber}',
                      style: context.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    3.toHeight,
                    Text(
                      order.customerName,
                      style: context.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Amount + status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${order.total}',
                    style: context.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.color.primaryContrastColor,
                    ),
                  ),
                  5.toHeight,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      6.toWidth,
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (order.paymentStatus == 'Paid'
                                  ? Colors.green
                                  : Colors.red)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.paymentStatus,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: order.paymentStatus == 'Paid'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Tickets List ──────────────────────────────────────────────────────────────

class _TicketsList extends StatelessWidget {
  final List<RecentTicket> tickets;
  const _TicketsList({required this.tickets});

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent': return Colors.red;
      case 'high':   return Colors.orange;
      case 'normal': return Colors.blue;
      case 'low':    return Colors.grey;
      default:       return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No recent tickets',
            style: context.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Colors.grey.withOpacity(0.15),
      ),
      itemBuilder: (context, i) {
        final ticket = tickets[i];
        final pColor = _priorityColor(ticket.priority);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: pColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.support_agent_outlined,
                    size: 18, color: pColor),
              ),
              12.toWidth,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: context.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.toHeight,
                    Text(
                      ticket.customerName,
                      style: context.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              10.toWidth,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ticket.status == 'open'
                          ? Colors.green.withOpacity(0.12)
                          : Colors.grey.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ticket.status == 'open'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ),
                  5.toHeight,
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: pColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: pColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}