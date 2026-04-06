import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminReportViewModel.dart';
import 'package:car_service/services/admin_services/AdminReportService.dart';
import 'package:car_service/helper/pdf_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminReportListView extends StatefulWidget {
  const AdminReportListView({super.key});

  @override
  State<AdminReportListView> createState() => _AdminReportListViewState();
}

class _AdminReportListViewState extends State<AdminReportListView> with SingleTickerProviderStateMixin {
  late AdminReportViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel = AdminReportViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'Revenue'),
            Tab(text: 'Orders Status'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRevenueTab(),
          _buildOrderStatusTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generatePdf(),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: const Text('Generate PDF', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildRevenueTab() {
    return Consumer<AdminReportService>(
      builder: (context, service, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateFilter(),
              const SizedBox(height: 20),
              _buildSummaryCards(service),
              const SizedBox(height: 20),
              _buildRevenueTable(service),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusTab() {
    return Consumer<AdminReportService>(
      builder: (context, service, child) {
         if (service.loading && service.orderReport.data.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummaryCards(service),
              const SizedBox(height: 20),
              _buildOrderTable(service),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateFilter() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateRange(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date Range', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${_viewModel.fromDate} to ${_viewModel.toDate}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(color: Colors.grey[300]),
                const Icon(Icons.calendar_month, color: primaryColor),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                 const Text('Group By:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                 const SizedBox(width: 12),
                 _buildGroupChip('day', 'Day'),
                 8.toWidth,
                 _buildGroupChip('week', 'Week'),
                 8.toWidth,
                 _buildGroupChip('month', 'Month'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupChip(String value, String label) {
    final isSelected = _viewModel.groupBy == value;
    return GestureDetector(
      onTap: () => _viewModel.setGroupBy(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? primaryColor : Colors.grey[600], fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildSummaryCards(AdminReportService service) {
    final report = service.revenueReport.data;
    final totalOrders = report.fold(0, (s, r) => s + r.orderCount);
    final totalRevenue = report.fold(0.0, (s, r) => s + r.totalRevenue);

    return Row(
      children: [
        Expanded(child: _buildStatTile('Total Orders', totalOrders.toString(), Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatTile('Total Revenue', '₹${totalRevenue.toStringAsFixed(0)}', Colors.green)),
      ],
    );
  }

  Widget _buildOrderSummaryCards(AdminReportService service) {
    final report = service.orderReport.data;
    final totalCount = report.fold(0, (s, r) => s + r.count);
    final totalAmount = report.fold(0.0, (s, r) => s + r.totalAmount);

    return Row(
      children: [
        Expanded(child: _buildStatTile('Total Orders', totalCount.toString(), Colors.purple)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatTile('Total Amount', '₹${totalAmount.toStringAsFixed(0)}', Colors.orange)),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildRevenueTable(AdminReportService service) {
    if (service.loading) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    if (service.revenueReport.data.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No data found')));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 12,
        columns: const [
          DataColumn(label: Text('Period', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          DataColumn(label: Text('Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          DataColumn(label: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
        rows: service.revenueReport.data.map((row) => DataRow(
          cells: [
            DataCell(Text(row.period, style: const TextStyle(fontSize: 12))),
            DataCell(Text(row.orderCount.toString(), style: const TextStyle(fontSize: 12))),
            DataCell(Text('₹${row.totalRevenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildOrderTable(AdminReportService service) {
    if (service.orderReport.data.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No data found')));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 12,
        columns: const [
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          DataColumn(label: Text('Count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
        rows: service.orderReport.data.map((row) => DataRow(
          cells: [
            DataCell(Text(row.statusLabel, style: const TextStyle(fontSize: 12))),
            DataCell(Text(row.count.toString(), style: const TextStyle(fontSize: 12))),
            DataCell(Text('₹${row.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ],
        )).toList(),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateFormat('yyyy-MM-dd').parse(_viewModel.fromDate),
        end: DateFormat('yyyy-MM-dd').parse(_viewModel.toDate),
      ),
      builder: (context, child) {
        return Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: primaryColor)), child: child!);
      },
    );
    if (picked != null) {
      _viewModel.setDateRange(picked.start, picked.end);
    }
  }

  void _generatePdf() {
    final service = Provider.of<AdminReportService>(context, listen: false);
    if (_tabController.index == 0) {
      PdfHelper.generateRevenuePdf(service.revenueReport.data, _viewModel.fromDate, _viewModel.toDate);
    } else {
      PdfHelper.generateOrderPdf(service.orderReport.data);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
