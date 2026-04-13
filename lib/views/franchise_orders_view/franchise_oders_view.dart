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
import '../../helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../invoice_view/invoice_view.dart' show downloadInvoicePdf;

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
              _StatusFilterSection(os: os),
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

  // ── Helper Sheets (Shared with _OrderCard via context) ───────────────────────

  static void showStatusSheet(BuildContext context, FranchiseOrderItem order,
      FranchiseOrdersService os) {
    final List<Map<String, dynamic>> options = [
      {'label': 'Pending', 'value': 0, 'color': Colors.orange},
      {'label': 'Accepted', 'value': 1, 'color': Colors.blue},
      {'label': 'In Progress', 'value': 2, 'color': Colors.indigo},
      {'label': 'Completed', 'value': 3, 'color': Colors.green},
      {'label': 'Cancelled', 'value': 4, 'color': Colors.red},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionSheet(
        title: 'Update Order Status',
        options: options,
        currentValue: order.statusCode,
        onSelect: (val) async {
          final success = await os.updateOrderStatus(order.id, val);
          if (success) os.refreshOrders();
        },
      ),
    );
  }

  static void showPaymentSheet(BuildContext context, FranchiseOrderItem order,
      FranchiseOrdersService os) {
    final List<Map<String, dynamic>> options = [
      {'label': 'Unpaid', 'value': 0, 'color': Colors.red},
      {'label': 'Paid', 'value': 1, 'color': Colors.green},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionSheet(
        title: 'Update Payment Status',
        options: options,
        currentValue: order.paymentStatusCode,
        onSelect: (val) async {
          final success = await os.updatePaymentStatus(order.id, val);
          if (success) os.refreshOrders();
        },
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

                // 3. Core Info Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Invoice Tag & Hero Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            8.toWidth,
                            Text(
                              '₹${order.total}',
                              style: context.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: context.color.primaryContrastColor,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        16.toHeight,

                        // Footer Row: Metadata Chips & Status Badges
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Metadata Group
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _MetaIcon(
                                  icon: Icons.calendar_today_rounded,
                                  label: order.createdAt.toOrderTime,
                                ),
                                10.toWidth,
                                _MetaIcon(
                                  icon: Icons.inventory_2_outlined,
                                  label: '${order.itemsCount} Items',
                                ),
                              ],
                            ),
                            // Badges Group
                            Row(
                              mainAxisSize: MainAxisSize.min,
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

                        16.toHeight,
                        const Divider(height: 1),
                        12.toHeight,

                        // Quick Actions
                        Consumer<FranchiseOrdersService>(
                          builder: (context, os, _) => Row(
                            children: [
                              Expanded(
                                child: _QuickActionButton(
                                  label: 'Status',
                                  icon: Icons.edit_note_rounded,
                                  color: primaryColor,
                                  onTap: () => FranchiseOrdersView.showStatusSheet(context, order, os),
                                ),
                              ),
                              8.toWidth,
                              Expanded(
                                child: _QuickActionButton(
                                  label: 'Payment',
                                  icon: Icons.payments_outlined,
                                  color: Colors.indigo,
                                  onTap: () => FranchiseOrdersView.showPaymentSheet(context, order, os),
                                ),
                              ),
                              8.toWidth,
                              Material(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  onTap: () {
                                    downloadInvoicePdf(
                                      context,
                                      orderId: order.id,
                                      invoiceNumber: order.invoiceNumber,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: const Icon(Icons.download_rounded, size: 18, color: Colors.blueGrey),
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

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.15)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              6.toWidth,
              Text(
                label,
                style: context.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionSheet extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> options;
  final int currentValue;
  final Function(int) onSelect;

  const _OptionSheet({
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.accentContrastColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          20.toHeight,
          Text(
            title,
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          20.toHeight,
          ...options.map((opt) {
            final isSelected = opt['value'] == currentValue;
            final color = opt['color'] as Color;

            return ListTile(
              onTap: () {
                onSelect(opt['value']);
                Navigator.pop(context);
              },
              leading: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: isSelected ? color : Colors.grey[300],
              ),
              title: Text(
                opt['label'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : context.color.primaryContrastColor,
                ),
              ),
              trailing: isSelected
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Current', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  : null,
            );
          }),
        ],
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
      if (isFrom) {
        // Validation: Start Date cannot be in the future (relative to today or end date)
        if (selectedDate.isAfter(DateTime.now())) {
          "Start date cannot be in the future".showToast();
          return;
        }

        if (os.dateTo != null) {
          final toDate = DateTime.tryParse(os.dateTo!);
          if (toDate != null && selectedDate.isAfter(toDate)) {
            "Start date cannot be after end date".showToast();
            return;
          }
        }
      } else {
        // Validation: End Date cannot be before Start Date
        if (os.dateFrom != null) {
          final fromDate = DateTime.tryParse(os.dateFrom!);
          if (fromDate != null && selectedDate.isBefore(fromDate)) {
            "End date cannot be before start date".showToast();
            return;
          }
        }
      }

      final formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      if (isFrom) {
        os.setFilters(from: formattedDate, to: os.dateTo, status: os.status);
      } else {
        os.setFilters(from: os.dateFrom, to: formattedDate, status: os.status);
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

class _StatusFilterSection extends StatelessWidget {
  final FranchiseOrdersService os;

  const _StatusFilterSection({required this.os});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> statuses = [
      {'label': 'All', 'value': null},
      {'label': 'Pending', 'value': '0', 'color': Colors.orange},
      {'label': 'Accepted', 'value': '1', 'color': Colors.blue},
      {'label': 'In Progress', 'value': '2', 'color': Colors.indigo},
      {'label': 'Completed', 'value': '3', 'color': Colors.green},
      {'label': 'Cancelled', 'value': '4', 'color': Colors.red},
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, __) => 8.toWidth,
        itemBuilder: (context, i) {
          final item = statuses[i];
          final isSelected = os.status == item['value'];
          final color = item['color'] as Color? ?? primaryColor;

          return ChoiceChip(
            label: Text(
              item['label'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : color,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                os.setFilters(
                  status: item['value'],
                  from: os.dateFrom,
                  to: os.dateTo,
                );
                os.refreshOrders();
              }
            },
            selectedColor: color,
            backgroundColor: color.withOpacity(0.05),
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: isSelected ? color : color.withOpacity(0.2),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          );
        },
      ),
    );
  }
}
