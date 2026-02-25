// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT: franchise_order_breakdown.dart
// Location: lib/views/Franchise_home_view/components/franchise_order_breakdown.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/franchise_models/franchise_dashboard_model.dart';
import 'package:flutter/material.dart';

class FranchiseOrderBreakdown extends StatelessWidget {
  final FranchiseOrderCountsModel orderCounts;

  const FranchiseOrderBreakdown({super.key, required this.orderCounts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
            Text(
              'Order Breakdown',
              style: context.titleMedium?.bold,
            ),
            16.toHeight,

            // ── Status row ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatusChip(
                    label: LocalKeys.pending,
                    count: orderCounts.pending,
                    color: Colors.orange,
                    icon: Icons.pending_actions_outlined,
                  ),
                ),
                8.toWidth,
                Expanded(
                  child: _StatusChip(
                    label: 'Active',
                    count: orderCounts.active,
                    color: Colors.blue,
                    icon: Icons.sync_outlined,
                  ),
                ),
                8.toWidth,
                Expanded(
                  child: _StatusChip(
                    label: LocalKeys.complete,
                    count: orderCounts.completed,
                    color: Colors.green,
                    icon: Icons.check_circle_outlined,
                  ),
                ),
                8.toWidth,
                Expanded(
                  child: _StatusChip(
                    label: LocalKeys.canceled,
                    count: orderCounts.cancelled,
                    color: Colors.red,
                    icon: Icons.cancel_outlined,
                  ),
                ),
              ],
            ),

            16.toHeight,
            Divider(
                color: context.color.primaryBorderColor,
                height: 1,
                thickness: 1),
            16.toHeight,

            // ── Payment row ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _PaymentRow(
                    label: 'Paid',
                    count: orderCounts.paid,
                    color: Colors.green,
                    icon: Icons.check_circle_outline,
                    total: orderCounts.total,
                  ),
                ),
                16.toWidth,
                Expanded(
                  child: _PaymentRow(
                    label: 'Unpaid',
                    count: orderCounts.unpaid,
                    color: Colors.red,
                    icon: Icons.money_off_outlined,
                    total: orderCounts.total,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          6.toHeight,
          Text(
            count.toString(),
            style: context.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          3.toHeight,
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Payment Row ───────────────────────────────────────────────────────────────

class _PaymentRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final int total;

  const _PaymentRow({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            6.toWidth,
            Text(
              label,
              style: context.bodySmall?.copyWith(
                color: context.color.secondaryContrastColor.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            Text(
              count.toString(),
              style: context.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        6.toHeight,
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}