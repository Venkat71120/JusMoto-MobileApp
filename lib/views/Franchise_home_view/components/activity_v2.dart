// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT: franchise_activity_section.dart
// Location: lib/views/Franchise_home_view/components/franchise_activity_section.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/franchise_models/franchise_dashboard_model.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FranchiseActivitySection extends StatelessWidget {
  const FranchiseActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseDashboardService>(
      builder: (context, ds, _) {
        if (ds.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final recentOrders = ds.dashboardData?.recentOrders ?? [];
        final recentTickets = ds.dashboardData?.recentTickets ?? [];

        return Column(
          children: [
            // ── Recent Orders ──────────────────────────────────────────────────
            _SectionHeader(
              title: LocalKeys.recentOrders,
              onTap: () {},
            ),
            _OrdersList(orders: recentOrders),

            24.toHeight,

            // ── Recent Tickets ─────────────────────────────────────────────────
            _SectionHeader(
              title: LocalKeys.recentTickets,
              onTap: () {},
            ),
            _TicketsList(tickets: recentTickets),
            
            32.toHeight,
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: context.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Row(
              children: [
                Text('View all', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
      return _EmptyActivity(message: 'No recent orders found');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => 12.toHeight,
      itemBuilder: (context, i) {
        final order = orders[i];
        final statusColor = _statusColor(order.statusCode);
        final isPaid = order.paymentStatus == 'Paid';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [statusColor, statusColor.withOpacity(0.3)],
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                            image: order.image != null
                                ? DecorationImage(
                                    image: NetworkImage(order.image!),
                                    fit: BoxFit.cover,
                                    onError: (e, s) => const Icon(Icons.broken_image, size: 14),
                                  )
                                : null,
                          ),
                          child: order.image == null
                              ? Icon(Icons.shopping_bag_outlined, color: Colors.grey[200], size: 24)
                              : null,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.invoiceNumber}',
                            style: context.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                              letterSpacing: 0.5,
                              fontSize: 10,
                            ),
                          ),
                          4.toHeight,
                          Text(
                            order.customerName,
                            style: context.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.color.primaryContrastColor.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${order.total}',
                          style: context.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: context.color.primaryContrastColor,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _CompactV2Badge(label: order.status, color: statusColor, isSolid: true),
                            4.toWidth,
                            _CompactV2Badge(label: order.paymentStatus, color: isPaid ? Colors.green : Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TicketsList extends StatelessWidget {
  final List<RecentTicket> tickets;
  const _TicketsList({required this.tickets});

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent': return Colors.red;
      case 'high':   return Colors.orange;
      case 'normal': return Colors.blue;
      default:       return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return _EmptyActivity(message: 'No recent tickets found');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => 10.toHeight,
      itemBuilder: (context, i) {
        final ticket = tickets[i];
        final pColor = _priorityColor(ticket.priority);
        final statusColor = ticket.status.toLowerCase() == 'open' ? Colors.green : Colors.grey;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [pColor, pColor.withOpacity(0.3)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.support_agent_rounded, size: 20, color: pColor),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.title,
                            style: context.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.color.primaryContrastColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.toHeight,
                          Text(
                            ticket.customerName,
                            style: context.bodySmall?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _CompactV2Badge(
                          label: ticket.status.toUpperCase(),
                          color: statusColor,
                          isSolid: ticket.status.toLowerCase() == 'open',
                        ),
                        const Spacer(),
                        Text(
                          ticket.priority.toUpperCase(),
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: pColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  final String message;
  const _EmptyActivity({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey[200], size: 40),
            12.toHeight,
            Text(
              message,
              style: context.bodyMedium?.copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactV2Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSolid;

  const _CompactV2Badge({required this.label, required this.color, this.isSolid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isSolid ? color : color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(100),
        border: isSolid ? null : Border.all(color: color.withOpacity(0.15), width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          color: isSolid ? Colors.white : color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
