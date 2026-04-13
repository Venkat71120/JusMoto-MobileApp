import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminCatalogViewModel.dart';
import 'package:car_service/services/admin_services/AdminCatalogService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminCategoryFormView.dart';

class AdminCategoryListView extends StatefulWidget {
  const AdminCategoryListView({super.key});

  @override
  State<AdminCategoryListView> createState() => _AdminCategoryListViewState();
}

class _AdminCategoryListViewState extends State<AdminCategoryListView> {
  late AdminCatalogViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminCatalogViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
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
                if (service.loading && service.categoryList.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.categoryList.categories.isEmpty) {
                  return const Center(child: Text('No categories found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchCategories(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.categoryList.categories.length + (service.categoryList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.categoryList.categories.length) {
                        _viewModel.fetchCategories(page: service.categoryList.pagination.currentPage + 1);
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                      }

                      final category = service.categoryList.categories[index];
                      return _buildCategoryCard(category);
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
            MaterialPageRoute(builder: (context) => const AdminCategoryFormView()),
          ).then((_) => _viewModel.fetchCategories());
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _viewModel.categorySearchController,
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: _viewModel.onCategorySearchChanged,
          ),
          if (_viewModel.categorySearchController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _FilterChip(label: 'Search: ${_viewModel.categorySearchController.text}', onClear: () {
                   _viewModel.categorySearchController.clear();
                   _viewModel.fetchCategories();
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryCard(category) {
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: category.image != null
                    ? Image.network(category.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.category, color: Colors.grey))
                    : const Icon(Icons.category, color: Colors.grey),
              ),
              title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: PopupMenuButton<String>(
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: const Text('Edit Category'),
                  ),
                  PopupMenuItem<String>(
                    value: 'status',
                    child: Text(category.status == 1 ? 'Mark Inactive' : 'Mark Active'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete Category', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminCategoryFormView(category: category)),
                    ).then((_) => _viewModel.fetchCategories());
                  } else if (val == 'status') {
                    _showStatusDialog(category);
                  } else if (val == 'delete') {
                    _showDeleteDialog(category);
                  }
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(
                  category.status == 1 ? 'Active' : 'Inactive',
                  category.status == 1 ? Colors.green : Colors.red,
                ),
                const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
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

  void _showStatusDialog(category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Text('Are you sure you want to change the status for ${category.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final status = category.status == 1 ? '0' : '1';
              Provider.of<AdminCatalogService>(context, listen: false).updateCategory(category.id, {'status': status}, null);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete ${category.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteCategory(category.id);
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
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _FilterChip({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          InkWell(
            onTap: onClear,
            child: Icon(Icons.close, size: 14, color: primaryColor),
          ),
        ],
      ),
    );
  }
}
