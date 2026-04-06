import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminCatalogViewModel.dart';
import 'package:car_service/services/admin_services/AdminCatalogService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminServiceFormView.dart';

class AdminServiceListView extends StatefulWidget {
  final int itemType; // 0=Service, 1=Product
  const AdminServiceListView({super.key, required this.itemType});

  @override
  State<AdminServiceListView> createState() => _AdminServiceListViewState();
}

class _AdminServiceListViewState extends State<AdminServiceListView> {
  late AdminCatalogViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminCatalogViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initServices(widget.itemType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.itemType == 0 ? 'Services' : 'Products';

    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: Text('$title Management', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<AdminCatalogService>(
              builder: (context, service, child) {
                if (service.loading && service.serviceList.services.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.serviceList.services.isEmpty) {
                  return Center(child: Text('No $title found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchServices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.serviceList.services.length + (service.serviceList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.serviceList.services.length) {
                        _viewModel.fetchServices(page: service.serviceList.pagination.currentPage + 1);
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                      }

                      final item = service.serviceList.services[index];
                      return _buildServiceCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminServiceFormView(itemType: widget.itemType)),
          ).then((_) => _viewModel.fetchServices());
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
              hintText: 'Search ${widget.itemType == 0 ? "services" : "products"}...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: _viewModel.onSearchChanged,
          ),
          12.toHeight,
          Row(
            children: [
              Expanded(
                child: _buildDropDown(
                  value: _viewModel.statusFilter,
                  hint: 'Status',
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All Status')),
                    DropdownMenuItem(value: '1', child: Text('Active')),
                    DropdownMenuItem(value: '0', child: Text('Inactive')),
                  ],
                  onChanged: (v) => _viewModel.onStatusFilterChanged(v),
                ),
              ),
              12.toWidth,
              Expanded(
                child: _buildDropDown(
                  value: _viewModel.featuredFilter,
                  hint: 'Featured',
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: '1', child: Text('Featured')),
                    DropdownMenuItem(value: '0', child: Text('Not Featured')),
                  ],
                  onChanged: (v) => _viewModel.onFeaturedFilterChanged(v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropDown({required String value, required String hint, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text(hint),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildServiceCard(item) {
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
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.image != null
                    ? Image.network(item.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey))
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category?.name ?? 'No Category', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('\u20B9${item.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
                ],
              ),
              trailing: PopupMenuButton<String>(
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: const Text('Edit Item'),
                  ),
                  PopupMenuItem<String>(
                    value: 'status',
                    child: Text(item.status == 1 ? 'Mark Inactive' : 'Mark Active'),
                  ),
                  PopupMenuItem<String>(
                    value: 'featured',
                    child: Text(item.isFeatured == 1 ? 'Remove Featured' : 'Mark Featured'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete Item', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminServiceFormView(itemType: widget.itemType, item: item)),
                    ).then((_) => _viewModel.fetchServices());
                  } else if (val == 'status') {
                    _viewModel.toggleStatus(item);
                  } else if (val == 'featured') {
                    _viewModel.toggleFeatured(item);
                  } else if (val == 'delete') {
                    _showDeleteDialog(item);
                  }
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildBadge(
                      item.status == 1 ? 'Active' : 'Inactive',
                      item.status == 1 ? Colors.green : Colors.red,
                    ),
                    8.toWidth,
                    if (item.isFeatured == 1)
                      _buildBadge('Featured', Colors.orange),
                  ],
                ),
                if (item.duration != null)
                  Text(item.duration!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showDeleteDialog(item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete ${item.title}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteService(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
