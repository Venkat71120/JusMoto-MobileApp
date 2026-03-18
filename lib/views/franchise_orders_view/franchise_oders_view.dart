// ─────────────────────────────────────────────────────────────────────────────
// VIEW: franchise_orders_view.dart
// Location: lib/views/franchise_orders_view/franchise_orders_view.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/franchise_models/franchise_order_model.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_orders_service.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/views/franchise_order_detail_view/franchise_order_detail_view.dart';
// import 'package:car_service/views/franchise_orders_view/franchise_order_detail_view.dart';
import '../../helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FranchiseOrdersView extends StatelessWidget {
  const FranchiseOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseOrdersService>(
      builder: (context, os, _) {
        // Auto-fetch on first render
        if (os.shouldAutoFetch) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            os.fetchOrders();
          });
        }

        return Scaffold(
          backgroundColor: context.color.backgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: context.color.backgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Text(
              LocalKeys.orders,
              style: context.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: os.isLoadingList ? null : () => os.refreshOrders(),
                tooltip: 'Refresh',
              ),
              SizedBoxExtension(12).toWidth,
            ],
          ),
          body: Column(
            children: [
              _FilterSection(os: os),
              Expanded(
                child: CustomRefreshIndicator(
                  onRefresh: () => os.refreshOrders(),
                  child: _buildBody(context, os),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FranchiseOrdersService os) {
    if (os.isLoadingList && os.shouldAutoFetch) {
      return const _OrdersListSkeleton();
    }

    if (os.hasListError && os.orderList.orders.isEmpty) {
      return _ErrorState(onRetry: () => os.fetchOrders());
    }

    if (os.orderList.orders.isEmpty) {
      return _EmptyState();
    }

    final orders = os.orderList.orders;
    final pagination = os.orderList.pagination;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: orders.length + (pagination.hasNextPage ? 1 : 0),
      separatorBuilder: (_, __) => 10.toHeight,
      itemBuilder: (context, i) {
        if (i == orders.length) {
          return _LoadMoreButton(onTap: () {
            os.fetchOrders(page: pagination.currentPage + 1);
          });
        }
        return _OrderCard(
          order: orders[i],
          onTap: () => _openDetail(context, orders[i].id),
        );
      },
    );
  }

  void _openDetail(BuildContext context, int orderId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FranchiseOrderDetailView(orderId: orderId),
      ),
    );
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final FranchiseOrderItem order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  Color _statusColor(int code) {
    switch (code) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.teal;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.statusCode);
    final isPaid = order.paymentStatusCode == 1;

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
        child: Column(
          children: [
            // ── Top row: invoice + amount ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  // Status dot
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.invoiceNumber}',
                          style: context.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        4.toHeight,
                        Text(
                          order.customer.name,
                          style: context.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${order.total}',
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ──────────────────────────────────────────────
            Divider(height: 1, color: Colors.grey.withOpacity(0.12)),

            // ── Bottom row: metadata + badges ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  // Metadata group (Date, schedule, count)
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 11, color: Colors.grey[500]),
                        4.toWidth,
                        Flexible(
                          child: Text(
                            order.createdAt.toOrderTime,
                            style: context.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        6.toWidth,
                        // Items count chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${order.itemsCount} item${order.itemsCount == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 9,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.toWidth,
                  // Status badge
                  _Badge(
                    label: order.status,
                    color: statusColor,
                  ),
                  4.toWidth,
                  // Payment badge
                  _Badge(
                    label: order.paymentStatus,
                    color: isPaid ? Colors.green : Colors.red,
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

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Load More Button ──────────────────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LoadMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton(
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Load more', style: TextStyle(color: primaryColor)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: primaryColor, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.grey[300]),
          16.toHeight,
          Text(
            LocalKeys.noOrdersFound,
            style: context.titleMedium?.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

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
          Text(
            'Failed to load orders',
            style: context.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
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

// ── Skeleton Loader ───────────────────────────────────────────────────────────

class _OrdersListSkeleton extends StatelessWidget {
  const _OrdersListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 6,
      separatorBuilder: (_, __) => 10.toHeight,
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.color.mutedContrastColor,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}


// ── Filter Section ────────────────────────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  final FranchiseOrdersService os;

  const _FilterSection({required this.os});

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final initialDate = DateTime.now();
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2100);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      final formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      if (isFrom) {
        os.setFilters(from: formattedDate, to: os.dateTo);
      } else {
        os.setFilters(from: os.dateFrom, to: formattedDate);
      }
      os.refreshOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = os.dateFrom != null || os.dateTo != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        color: context.color.backgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterItem(
              label: os.dateFrom ?? 'From Date',
              icon: Icons.calendar_today_rounded,
              isActive: os.dateFrom != null,
              onTap: () => _selectDate(context, true),
            ),
          ),
          8.toWidth,
          Expanded(
            child: _FilterItem(
              label: os.dateTo ?? 'To Date',
              icon: Icons.calendar_today_rounded,
              isActive: os.dateTo != null,
              onTap: () => _selectDate(context, false),
            ),
          ),
          if (hasFilters) ...[
            8.toWidth,
            IconButton.filled(
              onPressed: () {
                os.clearFilters();
                os.refreshOrders();
              },
              icon: const Icon(Icons.close_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? primaryColor.withOpacity(0.05)
              : context.color.mutedContrastColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? primaryColor.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isActive ? primaryColor : Colors.grey),
            8.toWidth,
            Expanded(
              child: Text(
                label,
                style: context.bodySmall?.copyWith(
                  color: isActive ? primaryColor : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
