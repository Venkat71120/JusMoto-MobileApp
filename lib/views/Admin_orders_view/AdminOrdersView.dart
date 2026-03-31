import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminOrdersViewModel.dart';
import 'package:car_service/services/admin_services/AdminOrdersService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> with SingleTickerProviderStateMixin {
  late AdminOrdersViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminOrdersViewModel(context);
    _tabController = TabController(length: _viewModel.statusTabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _viewModel.onStatusTabChanged(_viewModel.statusTabs[_tabController.index]['value']!);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Orders Management', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: _viewModel.statusTabs.map((tab) => Tab(text: tab['label'])).toList(),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<AdminOrdersService>(
              builder: (context, service, child) {
                if (service.loading && service.orderList.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.orderList.orders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.orderList.orders.length + (service.orderList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.orderList.orders.length) {
                        _viewModel.fetchOrders(page: service.orderList.pagination.currentPage + 1);
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                      }

                      final order = service.orderList.orders[index];
                      return _buildOrderCard(order);
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _viewModel.searchController,
            decoration: InputDecoration(
              hintText: 'Search by invoice, customer...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: _viewModel.onSearchChanged,
          ),
          12.toHeight,
          Row(
            children: [
              const Text('Payment: ', style: TextStyle(fontWeight: FontWeight.w600)),
              8.toWidth,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _viewModel.paymentFilter.isEmpty ? null : _viewModel.paymentFilter,
                      hint: const Text('All Payments'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All Payments')),
                        DropdownMenuItem(value: '1', child: Text('Paid')),
                        DropdownMenuItem(value: '0', child: Text('Unpaid')),
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
        ],
      ),
    );
  }

  Widget _buildOrderCard(order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(order.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  4.toHeight,
                  Text(order.customer.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(order.customer.email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text('₹${order.total}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                   Text(order.createdAt.split('T')[0], style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                ],
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(order),
                _buildPaymentChip(order),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Text('Change Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    ),
                    ...[0, 1, 2, 3, 4].map((s) => PopupMenuItem<String>(
                      value: 'status_$s',
                      child: Text(_getStatusLabel(s)),
                    )),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'payment',
                      child: Text(order.paymentStatusCode == 1 ? 'Mark Unpaid' : 'Mark Paid'),
                    ),
                  ],
                  onSelected: (val) {
                    if (val.toString().startsWith('status_')) {
                      final status = int.parse(val.toString().split('_')[1]);
                      _viewModel.updateOrderStatus(order.id, status);
                    } else if (val == 'payment') {
                      _viewModel.updatePaymentStatus(order.id, order.paymentStatusCode);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(order) {
    Color color;
    switch (order.statusCode) {
      case 0: color = Colors.orange; break;
      case 1: color = Colors.blue; break;
      case 2: color = Colors.purple; break;
      case 3: color = Colors.green; break;
      case 4: color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        order.statusLabel,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentChip(order) {
    final isPaid = order.paymentStatusCode == 1;
    final color = isPaid ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        order.paymentStatusLabel,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getStatusLabel(int code) {
    switch (code) {
      case 0: return 'Pending';
      case 1: return 'Accepted';
      case 2: return 'In Progress';
      case 3: return 'Completed';
      case 4: return 'Cancelled';
      default: return 'Unknown';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }
}
