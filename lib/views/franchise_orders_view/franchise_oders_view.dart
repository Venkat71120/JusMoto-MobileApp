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
              12.toWidth,
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
    final statusColor = _statusColor(order.statusCode);
    final isPaid = order.paymentStatusCode == 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: statusColor.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Dynamic Status Gradient Bar
                Container(
                  width: 7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusColor,
                        statusColor.withOpacity(0.4),
                        statusColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),

                // 2. Image Section with Floating Indicator
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 12, 20),
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.grey[50],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: order.firstItemImage != null
                              ? DecorationImage(
                                  image: NetworkImage(order.firstItemImage!),
                                  fit: BoxFit.cover,
                                  onError: (e, s) => const Icon(
                                      Icons.broken_image,
                                      size: 24,
                                      color: Colors.grey),
                                )
                              : null,
                        ),
                        child: order.firstItemImage == null
                            ? Icon(Icons.shopping_bag_outlined,
                                color: Colors.grey[200], size: 36)
                            : null,
                      ),
                    ),
                    // Floating Real-time Status Dot
                    Positioned(
                      top: 14,
                      right: 6,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 3. Core Info Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Invoice Tag & Hero Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '#${order.invoiceNumber}',
                                style: context.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                  fontSize: 10.5,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Text(
                              '₹${order.total}',
                              style: context.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: context.color.primaryContrastColor,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        14.toHeight,

                        // Customer Info with specialized icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person_outline_rounded,
                                  size: 12, color: Colors.grey[500]),
                            ),
                            10.toWidth,
                            Expanded(
                              child: Text(
                                order.customer.name,
                                style: context.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.color.primaryContrastColor
                                      .withOpacity(0.85),
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        16.toHeight,
                        const Spacer(),

                        // Footer Row: Metadata Chips & Status Badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Metadata Group
                            Row(
                              children: [
                                _MetaIcon(
                                  icon: Icons.calendar_today_rounded,
                                  label: order.createdAt.toOrderTime,
                                ),
                                14.toWidth,
                                _MetaIcon(
                                  icon: Icons.inventory_2_outlined,
                                  label: '${order.itemsCount} Items',
                                ),
                              ],
                            ),
                            // Badges Group
                            Row(
                              children: [
                                _V2Badge(
                                    label: order.status,
                                    color: statusColor,
                                    isSolid: true),
                                6.toWidth,
                                _V2Badge(
                                  label: order.paymentStatus,
                                  color: isPaid ? Colors.green : Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[400]),
        5.toWidth,
        Text(
          label,
          style: context.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _V2Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSolid;

  const _V2Badge(
      {required this.label, required this.color, this.isSolid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSolid ? color : color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(100),
        border: isSolid
            ? null
            : Border.all(color: color.withOpacity(0.15), width: 0.5),
        boxShadow: isSolid
            ? [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ]
            : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: isSolid ? Colors.white : color,
          letterSpacing: 0.6,
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
              ? primaryColor.withOpacity(0.06)
              : context.color.mutedContrastColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive 
                ? primaryColor.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 14, 
              color: isActive ? primaryColor : Colors.grey[400],
            ),
            10.toWidth,
            Expanded(
              child: Text(
                label,
                style: context.bodySmall?.copyWith(
                  color: isActive ? primaryColor : Colors.grey[500],
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
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
