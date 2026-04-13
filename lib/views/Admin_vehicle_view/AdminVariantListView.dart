import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminVehicleViewModel.dart';
import 'package:car_service/services/admin_services/AdminVehicleService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminVariantFormView.dart';

class AdminVariantListView extends StatefulWidget {
  const AdminVariantListView({super.key});

  @override
  State<AdminVariantListView> createState() => _AdminVariantListViewState();
}

class _AdminVariantListViewState extends State<AdminVariantListView> {
  late AdminVehicleViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminVehicleViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initVariants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Car Variants', style: TextStyle(fontWeight: FontWeight.bold)),
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
                if (service.loading && service.variantList.variants.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.variantList.variants.isEmpty) {
                  return const Center(child: Text('No variants found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchVariants(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.variantList.variants.length + (service.variantList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.variantList.variants.length) {
                        _viewModel.fetchVariants(page: service.variantList.pagination.currentPage + 1);
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                      }

                      final variant = service.variantList.variants[index];
                      return _buildVariantCard(variant);
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
            MaterialPageRoute(builder: (context) => const AdminVariantFormView()),
          ).then((_) => _viewModel.fetchVariants());
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
          Consumer<AdminVehicleService>(
            builder: (context, service, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _viewModel.carFilterForVariant,
                    hint: const Text('Filter by Car Model'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<int>(value: null, child: Text('All Cars')),
                      ...service.carList.cars.map((car) => DropdownMenuItem(
                        value: car.id,
                        child: Text('${car.brand?.name ?? ""} ${car.name}'),
                      )),
                    ],
                    onChanged: (v) => _viewModel.onCarFilterForVariantChanged(v),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVariantCard(variant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        title: Text(variant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          variant.car != null ? '${variant.car!.brand?.name ?? ""} ${variant.car!.name}' : 'No Car Assigned',
          style: TextStyle(color: primaryColor, fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: Text('Edit Variant')),
            const PopupMenuItem<String>(value: 'delete', child: Text('Delete Variant', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (val) {
            if (val == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminVariantFormView(variant: variant)),
              ).then((_) => _viewModel.fetchVariants());
            } else if (val == 'delete') {
              _showDeleteDialog(variant);
            }
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(variant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Variant', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete ${variant.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteVariant(variant.id);
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
