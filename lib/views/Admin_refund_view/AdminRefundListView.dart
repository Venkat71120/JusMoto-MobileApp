import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminRefundViewModel.dart';
import 'package:car_service/services/admin_services/AdminRefundService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminRefundListView extends StatefulWidget {
  const AdminRefundListView({super.key});

  @override
  State<AdminRefundListView> createState() => _AdminRefundListViewState();
}

class _AdminRefundListViewState extends State<AdminRefundListView> with SingleTickerProviderStateMixin {
  late AdminRefundViewModel _viewModel;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _viewModel = AdminRefundViewModel(context);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        int status = -1;
        if (_tabController.index == 1) status = 0;
        if (_tabController.index == 2) status = 1;
        if (_tabController.index == 3) status = 2;
        _viewModel.setFilter(status);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _viewModel.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Refund Management', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Consumer<AdminRefundService>(
        builder: (context, service, child) {
          if (service.loading && service.refundList.data.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.refundList.data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.currency_exchange, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No refund requests found', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _viewModel.init(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: service.refundList.data.length + (service.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == service.refundList.data.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                }

                final refund = service.refundList.data[index];
                return _buildRefundCard(refund);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRefundCard(refund) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(refund.orderInvoice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    _buildStatusBadge(refund.status),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      radius: 20,
                      child: const Icon(Icons.person_outline, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(refund.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(DateFormat('dd MMM yyyy, hh:mm a').format(refund.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      '₹${refund.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
                if (refund.cancelReason != null && refund.cancelReason!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('REASON FOR REFUND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text(refund.cancelReason!, style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (refund.status == 0) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _confirmUpdate(refund, 2),
                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  Container(width: 1, height: 24, color: Colors.grey[200]),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _confirmUpdate(refund, 1),
                      icon: const Icon(Icons.check, color: Colors.green, size: 18),
                      label: const Text('Approve', style: TextStyle(color: Colors.green)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    Color color;
    String label;
    switch (status) {
      case 1: color = Colors.green; label = 'Approved'; break;
      case 2: color = Colors.red; label = 'Rejected'; break;
      default: color = Colors.orange; label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _confirmUpdate(refund, int newStatus) {
    bool isApprove = newStatus == 1;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Refund' : 'Reject Refund', style: TextStyle(color: isApprove ? Colors.green : Colors.red)),
        content: Text('Are you sure you want to ${isApprove ? 'approve' : 'reject'} the refund of ₹${refund.amount.toStringAsFixed(0)} for order ${refund.orderInvoice}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.updateStatus(refund, newStatus);
            },
            style: TextButton.styleFrom(foregroundColor: isApprove ? Colors.green : Colors.red),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
