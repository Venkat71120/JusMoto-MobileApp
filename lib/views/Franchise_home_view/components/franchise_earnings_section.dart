// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT: franchise_earnings_section.dart
// Location: lib/views/Franchise_home_view/components/franchise_earnings_section.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/franchise_models/franchise_dashboard_model.dart';
import 'package:car_service/view_models/franchise_home_view_model/franchise_home_view_model.dart';
import 'package:flutter/material.dart';

class FranchiseEarningsSection extends StatelessWidget {
  final FranchiseEarningsModel earnings;
  final FranchiseHomeViewModel hvm;
  final ValueChanged<EarningsPeriod> onPeriodChanged;

  const FranchiseEarningsSection({
    super.key,
    required this.earnings,
    required this.hvm,
    required this.onPeriodChanged,
  });

  String _formatCurrency(num value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

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
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('Earnings', style: context.titleMedium?.bold),
            ),
            12.toHeight,

            // ── Period tab strip ───────────────────────────────────────────
            ValueListenableBuilder<EarningsPeriod>(
              valueListenable: hvm.earningsPeriod,
              builder: (context, period, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: EarningsPeriod.values.map((p) {
                      final isSelected = period == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => onPeriodChanged(p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _periodLabel(p),
                              style: context.bodySmall?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            // ── Earnings data grid ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Main earnings figure
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatCurrency(earnings.netEarnings),
                        style: context.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      8.toWidth,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'net earnings',
                          style: context.bodySmall?.copyWith(
                            color: context.color.secondaryContrastColor
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  16.toHeight,

                  // Grid of detail stats
                  Row(
                    children: [
                      Expanded(
                        child: _EarningDetailTile(
                          label: 'Gross',
                          value: _formatCurrency(earnings.totalEarnings),
                          icon: Icons.trending_up_rounded,
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _EarningDetailTile(
                          label: 'Tax',
                          value: _formatCurrency(earnings.totalTax),
                          icon: Icons.receipt_long_outlined,
                          color: Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _EarningDetailTile(
                          label: 'Orders',
                          value: earnings.orderCount.toString(),
                          icon: Icons.shopping_bag_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _EarningDetailTile(
                          label: 'Avg Order',
                          value: _formatCurrency(earnings.averageOrderValue),
                          icon: Icons.bar_chart_outlined,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(EarningsPeriod p) {
    switch (p) {
      case EarningsPeriod.today:
        return 'Today';
      case EarningsPeriod.week:
        return 'Week';
      case EarningsPeriod.month:
        return 'Month';
      case EarningsPeriod.all:
        return 'All';
    }
  }
}

// ── Earning Detail Tile ───────────────────────────────────────────────────────

class _EarningDetailTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _EarningDetailTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        6.toHeight,
        Text(
          value,
          style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        3.toHeight,
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}