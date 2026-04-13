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
          _buildActiveFilters(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _viewModel.searchController,
            decoration: InputDecoration(
              hintText: 'Search ${widget.itemType == 0 ? "services" : "products"}...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: Colors.grey[50],
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

  Widget _buildActiveFilters() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final List<Widget> chips = [];
        
        if (_viewModel.searchController.text.isNotEmpty) {
           chips.add(_buildChip('Search: ${_viewModel.searchController.text}', () {
               _viewModel.searchController.clear();
               _viewModel.fetchServices();
           }));
        }
        
        if (_viewModel.statusFilter.isNotEmpty) {
          chips.add(_buildChip(_viewModel.statusFilter == '1' ? 'Active' : 'Inactive', () => _viewModel.onStatusFilterChanged('')));
        }
        if (_viewModel.featuredFilter.isNotEmpty) {
          chips.add(_buildChip(_viewModel.featuredFilter == '1' ? 'Featured' : 'Not Featured', () => _viewModel.onFeaturedFilterChanged('')));
        }

        if (chips.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Wrap(spacing: 8, runSpacing: 8, children: chips),
        );
      },
    );
  }

  Widget _buildChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12, color: primaryColor)),
      backgroundColor: primaryColor.withOpacity(0.1),
      deleteIcon: const Icon(Icons.close, size: 14, color: primaryColor),
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
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
    final bool hasDiscount = item.discountPrice != null && item.discountPrice! > 0;

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
                child: item.image != null && item.image!.isNotEmpty
                    ? Image.network(item.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey))
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category?.name ?? 'No Category', style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600)),
                  4.toHeight,
                  Row(
                    children: [
                      if (hasDiscount) ...[
                        Text('\u20B9${item.discountPrice}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
                        8.toWidth,
                        Text('\u20B9${item.price}', style: TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      ] else ...[
                        Text('\u20B9${item.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit Item')])),
                  PopupMenuItem<String>(value: 'status', child: Row(children: [Icon(item.status == 1 ? Icons.block : Icons.check_circle, size: 18), const SizedBox(width: 8), Text(item.status == 1 ? 'Mark Inactive' : 'Mark Active')])),
                  PopupMenuItem<String>(value: 'featured', child: Row(children: [Icon(item.isFeatured == 1 ? Icons.star_border : Icons.star, size: 18), const SizedBox(width: 8), Text(item.isFeatured == 1 ? 'Remove Featured' : 'Mark Featured')])),
                  const PopupMenuItem<String>(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete Item', style: TextStyle(color: Colors.red))])),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.duration != null && item.duration!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                          4.toWidth,
                          Text(item.duration!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    Text(
                      'Created: ${item.category?.id != null ? "Recently" : "N/A"}', // Fallback if no specific date in model
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
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
        title: const Text('Delete Item', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
