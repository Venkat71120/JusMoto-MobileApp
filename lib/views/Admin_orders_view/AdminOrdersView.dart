import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminOrdersViewModel.dart';
import 'package:car_service/services/admin_services/AdminOrdersService.dart';
import 'package:car_service/views/Admin_orders_view/AdminOrderDetailView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView>
    with SingleTickerProviderStateMixin {
  late AdminOrdersViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminOrdersViewModel(context);
    _tabController = TabController(
        length: _viewModel.statusTabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _viewModel.onStatusTabChanged(
            _viewModel.statusTabs[_tabController.index]['value']!);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.init());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: Text('Orders',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: context.color.primaryContrastColor)),
        elevation: 0,
        backgroundColor: context.color.accentContrastColor,
        surfaceTintColor: context.color.accentContrastColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            decoration: BoxDecoration(
              color: context.color.accentContrastColor,
              border: Border(
                bottom: BorderSide(
                    color: context.color.primaryBorderColor.withOpacity(0.5)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: primaryColor,
              unselectedLabelColor: context.color.tertiaryContrastColo,
              indicatorColor: primaryColor,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13),
              tabs: _viewModel.statusTabs
                  .map((tab) => Tab(text: tab['label']))
                  .toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search & Filter ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: context.color.accentContrastColor,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.color.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _viewModel.searchController,
                      style: context.bodySmall,
                      decoration: InputDecoration(
                        hintText: 'Search orders...',
                        hintStyle: context.bodySmall
                            ?.copyWith(color: context.color.tertiaryContrastColo),
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 20,
                            color: context.color.tertiaryContrastColo),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: _viewModel.onSearchChanged,
                      onSubmitted: (_) => _viewModel.fetchOrders(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: context.color.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _viewModel.paymentFilter.isEmpty
                            ? null
                            : _viewModel.paymentFilter,
                        hint: Text('Payment',
                            style: context.bodySmall?.copyWith(
                                color: context.color.tertiaryContrastColo)),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: context.color.tertiaryContrastColo),
                        style: context.bodySmall?.copyWith(
                            color: context.color.primaryContrastColor),
                        items: [
                          DropdownMenuItem(
                              value: '',
                              child: Text('All',
                                  style: context.bodySmall)),
                          DropdownMenuItem(
                              value: '1',
                              child: Text('Paid',
                                  style: context.bodySmall)),
                          DropdownMenuItem(
                              value: '0',
                              child: Text('Unpaid',
                                  style: context.bodySmall)),
                        ],
                        onChanged: (val) {
                          _viewModel.onPaymentFilterChanged(val);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Order List ─────────────────────────────────────────────
          Expanded(
            child: Consumer<AdminOrdersService>(
              builder: (context, service, _) {
                if (service.loading && service.orderList.orders.isEmpty) {
                  return Center(
                      child: CircularProgressIndicator(color: primaryColor));
                }

                if (service.orderList.orders.isEmpty) {
                  return _EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'No orders found',
                  );
                }

                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () async => _viewModel.fetchOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: service.orderList.orders.length +
                        (service.orderList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.orderList.orders.length) {
                        _viewModel.fetchOrders(
                            page: service.orderList.pagination.currentPage + 1);
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor, strokeWidth: 2)),
                        );
                      }
                      return _OrderCard(
                        order: service.orderList.orders[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminOrderDetailView(
                                orderId: service.orderList.orders[index].id),
                          ),
                        ),
                        onStatusChange: (status) => _viewModel
                            .updateOrderStatus(
                                service.orderList.orders[index].id, status),
                        onPaymentToggle: () =>
                            _viewModel.updatePaymentStatus(
                                service.orderList.orders[index].id,
                                service.orderList.orders[index]
                                    .paymentStatusCode),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onTap;
  final Function(int) onStatusChange;
  final VoidCallback onPaymentToggle;

  const _OrderCard({
    required this.order,
    required this.onTap,
    required this.onStatusChange,
    required this.onPaymentToggle,
  });

  Color _statusColor(int code) {
    switch (code) {
      case 0: return Colors.orange;
      case 1: return Colors.blue;
      case 2: return Colors.purple;
      case 3: return Colors.green;
      case 4: return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sColor = _statusColor(order.statusCode);
    final isPaid = order.paymentStatusCode == 1;
    final pColor = isPaid ? Colors.green : Colors.orange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top: invoice + amount ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.receipt_outlined,
                        size: 18, color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.invoiceNumber,
                          style: context.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700),
                        ),
                        3.toHeight,
                        Text(
                          order.customer.fullName,
                          style: context.bodySmall?.copyWith(
                              color: context.color.secondaryContrastColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\u20B9${order.total}',
                        style: context.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800, color: primaryColor),
                      ),
                      3.toHeight,
                      Text(
                        order.createdAt.split('T')[0],
                        style: context.bodySmall?.copyWith(
                            color: context.color.tertiaryContrastColo,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Bottom: badges + actions ─────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: context.color.mutedContrastColor.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  _Chip(label: order.statusLabel, color: sColor),
                  const SizedBox(width: 8),
                  _Chip(label: order.paymentStatusLabel, color: pColor),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz_rounded,
                        size: 20,
                        color: context.color.tertiaryContrastColo),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          enabled: false,
                          child: Text('Change Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12))),
                      ...[0, 1, 2, 3, 4].map((s) => PopupMenuItem(
                          value: 'status_$s',
                          child: Text(_statusLabel(s),
                              style: const TextStyle(fontSize: 13)))),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                          value: 'payment',
                          child: Text(
                              isPaid ? 'Mark Unpaid' : 'Mark Paid',
                              style: const TextStyle(fontSize: 13))),
                    ],
                    onSelected: (val) {
                      if (val.startsWith('status_')) {
                        onStatusChange(int.parse(val.split('_')[1]));
                      } else if (val == 'payment') {
                        onPaymentToggle();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(int code) {
    switch (code) {
      case 0: return 'Pending';
      case 1: return 'Accepted';
      case 2: return 'In Progress';
      case 3: return 'Completed';
      case 4: return 'Cancelled';
      default: return 'Unknown';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: context.color.tertiaryContrastColo),
          12.toHeight,
          Text(message,
              style: context.bodyMedium?.copyWith(
                  color: context.color.tertiaryContrastColo)),
        ],
      ),
    );
  }
}
