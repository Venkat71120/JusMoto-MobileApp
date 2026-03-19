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
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, color: Colors.grey[300], size: 48),
              12.toHeight,
              Text(
                'No recent orders',
                style: context.bodyMedium?.copyWith(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orders.length,
      separatorBuilder: (_, __) => 12.toHeight,
      itemBuilder: (context, i) {
        final order = orders[i];
        final statusColor = _statusColor(order.statusCode);
        final isPaid = order.paymentStatus == 'Paid';

        return Container(
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: statusColor.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Mini Gradient Status Bar
                  Container(
                    width: 4.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          statusColor,
                          statusColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),

                  // 2. Condensed Image Section with Indicator
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            image: order.image != null
                                ? DecorationImage(
                                    image: NetworkImage(order.image!),
                                    fit: BoxFit.cover,
                                    onError: (e, s) => const Icon(
                                        Icons.broken_image,
                                        size: 14,
                                        color: Colors.grey),
                                  )
                                : null,
                          ),
                          child: order.image == null
                              ? Icon(Icons.shopping_bag_outlined,
                                  color: Colors.grey[200], size: 24)
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
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 3. Info Section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                              color: context.color.primaryContrastColor
                                  .withOpacity(0.85),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Amount and Badges
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${order.total}',
                          style: context.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: context.color.primaryContrastColor,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CompactV2Badge(
                              label: order.status,
                              color: statusColor,
                              isSolid: true,
                            ),
                            4.toWidth,
                            _CompactV2Badge(
                              label: order.paymentStatus,
                              color: isPaid ? Colors.green : Colors.red,
                            ),
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

class _CompactV2Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSolid;

  const _CompactV2Badge(
      {required this.label, required this.color, this.isSolid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isSolid ? color : color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(100),
        border: isSolid
            ? null
            : Border.all(color: color.withOpacity(0.15), width: 0.5),
        boxShadow: isSolid
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
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

// ── Tickets List ────────────────────────�    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => 10.toHeight,
      itemBuilder: (context, i) {
        final ticket = tickets[i];
        final pColor = _priorityColor(ticket.priority);
        final statusColor = ticket.status == 'open' ? Colors.green : Colors.grey;

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
                  // 1. Dynamic Priority Bar
                  Container(
                    width: 4.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          pColor,
                          pColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),

                  // 2. Icon Section
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

                  // 3. Info Section
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
                              fontSize: 13.5,
                              color: context.color.primaryContrastColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.toHeight,
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey[400]),
                              4.toWidth,
                              Text(
                                ticket.customerName,
                                style: context.bodySmall?.copyWith(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Badges Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _CompactV2Badge(
                          label: ticket.status.toUpperCase(),
                          color: statusColor,
                          isSolid: ticket.status == 'open',
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ticket.priority.toUpperCase(),
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              color: pColor,
                              letterSpacing: 0.5,
                            ),
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