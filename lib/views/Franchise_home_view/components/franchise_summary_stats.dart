// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT: franchise_summary_stats.dart
// Location: lib/views/Franchise_home_view/components/franchise_summary_stats.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/franchise_models/franchise_dashboard_model.dart';
import 'package:flutter/material.dart';

class FranchiseSummaryStats extends StatelessWidget {
  final FranchiseDashboardStatisticsModel statistics;

  const FranchiseSummaryStats({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalKeys.quickStats,
            style: context.titleMedium?.bold,
          ),
          14.toHeight,

          // ── Row 1: Orders + Tickets ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.shopping_bag_outlined,
                  label: LocalKeys.totalOrders,
                  value: statistics.orders.total.toString(),
                  subLabel: '${statistics.orders.today} today',
                  color: primaryColor,
                ),
              ),
              12.toWidth,
              Expanded(
                child: _StatCard(
                  icon: Icons.support_agent_outlined,
                  label: 'Total Tickets',
                  value: statistics.tickets.total.toString(),
                  subLabel: '${statistics.tickets.open} open',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          12.toHeight,

          // ── Row 2: Earnings full-width ────────────────────────────────────
          _EarningHighlightCard(stats: statistics.earnings),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subLabel;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              Text(
                subLabel,
                style: context.bodySmall?.copyWith(
                  color: context.color.secondaryContrastColor.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          12.toHeight,
          Text(
            value,
            style: context.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.color.primaryContrastColor,
            ),
          ),
          4.toHeight,
          Text(
            label,
            style: context.bodySmall?.copyWith(
              color: context.color.secondaryContrastColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Earnings Highlight Card (full-width gradient) ─────────────────────────────

class _EarningHighlightCard extends StatelessWidget {
  final EarningStats stats;
  const _EarningHighlightCard({required this.stats});

  String _formatCurrency(num value) {
    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.white70, size: 16),
                    8.toWidth,
                    Text(
                      'Total Earnings',
                      style: context.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
                8.toHeight,
                Text(
                  _formatCurrency(stats.total),
                  style: context.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                4.toHeight,
                Text(
                  'Net: ${_formatCurrency(stats.netTotal)}',
                  style: context.bodySmall?.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _miniStat(context, 'This Week', _formatCurrency(stats.thisWeek)),
              8.toHeight,
              _miniStat(context, 'This Month', _formatCurrency(stats.thisMonth)),
              8.toHeight,
              _miniStat(context, 'Today', _formatCurrency(stats.today)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value,
            style: context.bodyMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: context.bodySmall?.copyWith(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}