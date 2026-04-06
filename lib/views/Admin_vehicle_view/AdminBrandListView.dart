import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminVehicleViewModel.dart';
import 'package:car_service/services/admin_services/AdminVehicleService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminBrandFormView.dart';

class AdminBrandListView extends StatefulWidget {
  const AdminBrandListView({super.key});

  @override
  State<AdminBrandListView> createState() => _AdminBrandListViewState();
}

class _AdminBrandListViewState extends State<AdminBrandListView> {
  late AdminVehicleViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminVehicleViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initBrands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Vehicle Brands', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<AdminVehicleService>(
              builder: (context, service, child) {
                if (service.loading && service.brandList.brands.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.brandList.brands.isEmpty) {
                  return const Center(child: Text('No brands found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchBrands(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.brandList.brands.length,
                    itemBuilder: (context, index) {
                      final brand = service.brandList.brands[index];
                      return _buildBrandCard(brand);
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
            MaterialPageRoute(builder: (context) => const AdminBrandFormView()),
          ).then((_) => _viewModel.fetchBrands());
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
      child: TextField(
        controller: _viewModel.brandSearchController,
        decoration: InputDecoration(
          hintText: 'Search brands...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: _viewModel.onBrandSearchChanged,
      ),
    );
  }

  Widget _buildBrandCard(brand) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: brand.image != null
              ? Image.network(brand.image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.stars, color: Colors.grey))
              : const Icon(Icons.stars, color: Colors.grey),
        ),
        title: Text(brand.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminBrandFormView(brand: brand)),
                ).then((_) => _viewModel.fetchBrands());
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _showDeleteDialog(brand),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(brand) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brand', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete ${brand.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteBrand(brand.id);
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
