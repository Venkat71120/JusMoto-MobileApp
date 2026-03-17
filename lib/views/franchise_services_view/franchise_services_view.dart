// ─────────────────────────────────────────────────────────────────────────────
// VIEW: franchise_services_view.dart
// Location: lib/views/franchise_services_view/franchise_services_view.dart
//
// The "Services" tab in FranchiseLandingView (index 2).
// Shows ticket statistics in a collapsing header + a filterable ticket list.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/franchise_models/franchise_ticket_model.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_tickets_service.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
// import 'package:car_service/views/franchise_services_view/franchise_ticket_detail_view.dart';
import 'package:car_service/views/franchise_ticket_detail_view/franchise_ticket_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FranchiseServicesView extends StatefulWidget {
  const FranchiseServicesView({super.key});

  @override
  State<FranchiseServicesView> createState() => _FranchiseServicesViewState();
}

class _FranchiseServicesViewState extends State<FranchiseServicesView> {
  // "all" | "open" | "close"
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseTicketsService>(
      builder: (context, ts, _) {
        if (ts.shouldAutoFetch) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => ts.fetchAll());
        }

        final filtered = _applyFilter(ts.ticketList.tickets);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: context.color.backgroundColor,
            body: CustomRefreshIndicator(
              onRefresh: () => ts.refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Collapsing stats header ──────────────────────────
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: primaryColor,
                    surfaceTintColor: primaryColor,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: _StatsHeader(
                        stats: ts.statistics,
                        isLoading: ts.isLoadingList && ts.shouldAutoFetch,
                      ),
                    ),
                    title: Text(
                      'Services',
                      style: context.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white),
                        onPressed:
                            ts.isLoadingList ? null : () => ts.refresh(),
                      ),
                      SizedBoxExtension(12).toWidth,
                    ],
                  ),

                  // ── Filter strip ─────────────────────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _FilterBarDelegate(
                      filter: _filter,
                      stats: ts.statistics,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                  ),

                  // ── List body ────────────────────────────────────────
                  if (ts.isLoadingList && ts.shouldAutoFetch)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _TicketListSkeleton(),
                    )
                  else if (ts.hasListError && filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ErrorState(onRetry: () => ts.fetchAll()),
                    )
                  else if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TicketCard(
                              ticket: filtered[i],
                              onTap: () =>
                                  _openDetail(context, filtered[i].id),
                            ),
                          ),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<FranchiseTicketItem> _applyFilter(List<FranchiseTicketItem> all) {
    if (_filter == 'all') return all;
    // Map 'closed' filter to match API value 'closed' OR 'close'
    final f = _filter == 'closed' ? 'closed' : _filter;
    return all.where((t) {
      final status = t.status.toLowerCase();
      final target = f.toLowerCase();
      return status == target || (target == 'closed' && status == 'close');
    }).toList();
  }

  void _openDetail(BuildContext context, int ticketId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FranchiseTicketDetailView(ticketId: ticketId),
      ),
    );
  }
}

// ── Stats Header ──────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  final FranchiseTicketStatisticsModel stats;
  final bool isLoading;

  const _StatsHeader({required this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 56, 20, 20),
      child: isLoading
          ? const _StatsHeaderSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total + sub-label
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stats.total.toString(),
                      style: context.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 42,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'total tickets',
                        style: context.bodySmall
                            ?.copyWith(color: Colors.white60),
                      ),
                    ),
                  ],
                ),
                12.toHeight,
                // Open / Closed / Priority row
                Row(
                  children: [
                    _StatPill(
                      label: 'Open',
                      value: stats.open,
                      color: Colors.greenAccent,
                    ),
                    SizedBoxExtension(10).toWidth,
                    _StatPill(
                      label: 'In Progress',
                      value: stats.inProgress,
                      color: Colors.orangeAccent,
                    ),
                    SizedBoxExtension(10).toWidth,
                    _StatPill(
                      label: 'Closed',
                      value: stats.closed,
                      color: Colors.white54,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBoxExtension(6).toWidth,
          Text(
            '$value $label',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsHeaderSkeleton extends StatelessWidget {
  const _StatsHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
            width: 100,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            )),
        12.toHeight,
        Row(
          children: [
            Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                )),
            SizedBoxExtension(10).toWidth,
            Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                )),
          ],
        ),
      ],
    );
  }
}

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final String filter;
  final FranchiseTicketStatisticsModel stats;
  final ValueChanged<String> onChanged;

  _FilterBarDelegate({
    required this.filter,
    required this.stats,
    required this.onChanged,
  });

  @override
  double get minExtent => 54;
  @override
  double get maxExtent => 54;

  @override
  bool shouldRebuild(_FilterBarDelegate old) =>
      old.filter != filter || old.stats != stats;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 54,
      child: Container(
        color: context.color.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                  label: 'All (${stats.total})',
                  selected: filter == 'all',
                  onTap: () => onChanged('all')),
              SizedBoxExtension(10).toWidth,
              _FilterChip(
                  label: 'Open (${stats.open})',
                  selected: filter == 'open',
                  onTap: () => onChanged('open')),
              SizedBoxExtension(10).toWidth,
              _FilterChip(
                  label: 'Progress (${stats.inProgress})',
                  selected: filter == 'in_progress',
                  onTap: () => onChanged('in_progress')),
              SizedBoxExtension(10).toWidth,
              _FilterChip(
                  label: 'Closed (${stats.closed})',
                  selected: filter == 'closed',
                  onTap: () => onChanged('closed')),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? primaryColor : primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : primaryColor,
          ),
        ),
      ),
    );
  }
}

// ── Ticket Card ───────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final FranchiseTicketItem ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusSafe = ticket.status.toString();
    final pColor = _priorityColor(ticket.priority.toString());
    final isOpen = statusSafe.toLowerCase() == 'open' || statusSafe == '1';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left priority stripe
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: pColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ticket.title,
                              style: context.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBoxExtension(10).toWidth,
                          // Status badge
                          _SmallBadge(
                            label: ticket.status.toUpperCase(),
                            color: isOpen ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                      6.toHeight,

                      // Department
                      Row(
                        children: [
                          Icon(Icons.business_outlined,
                              size: 13, color: Colors.grey[400]),
                          SizedBoxExtension(4).toWidth,
                          Text(
                            ticket.department,
                            style: context.bodySmall
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                          if (ticket.orderId != null) ...[
                            SizedBoxExtension(12).toWidth,
                            Icon(Icons.receipt_outlined,
                                size: 13, color: Colors.grey[400]),
                            SizedBoxExtension(4).toWidth,
                            Text(
                              'Order #${ticket.orderId}',
                              style: context.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                      8.toHeight,

                      // Bottom row: customer + priority + last message
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                ticket.customer.name.isNotEmpty
                                    ? ticket.customer.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          SizedBoxExtension(6).toWidth,
                          Expanded(
                            child: Text(
                              ticket.customer.name,
                              style: context.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Priority badge
                          _SmallBadge(
                            label: ticket.priority.toUpperCase(),
                            color: pColor,
                          ),
                        ],
                      ),

                      // Last message preview
                      if (ticket.lastMessage != null &&
                          ticket.lastMessage!.isNotEmpty) ...[
                        8.toHeight,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.color.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                ticket.lastMessageType == 'admin'
                                    ? Icons.support_agent_outlined
                                    : Icons.person_outline_rounded,
                                size: 13,
                                color: Colors.grey[400],
                              ),
                              SizedBoxExtension(6).toWidth,
                              Expanded(
                                child: Text(
                                  ticket.lastMessage!,
                                  style: context.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Chevron
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded,
                    color: Colors.grey[300], size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Empty / Error / Skeleton ──────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent_outlined, size: 72, color: Colors.grey[300]),
          16.toHeight,
          Text(
            'No tickets found',
            style: context.titleMedium?.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey[300]),
          16.toHeight,
          Text('Failed to load tickets',
              style: context.bodyMedium?.copyWith(color: Colors.grey[500])),
          16.toHeight,
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketListSkeleton extends StatelessWidget {
  const _TicketListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: context.color.mutedContrastColor,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

extension _WidthExt on int {
  Widget get toWidth => SizedBox(width: toDouble());
}