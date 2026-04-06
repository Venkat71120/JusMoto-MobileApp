import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminVehicleViewModel.dart';
import 'package:car_service/services/admin_services/AdminVehicleService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminCarFormView.dart';

class AdminCarListView extends StatefulWidget {
  const AdminCarListView({super.key});

  @override
  State<AdminCarListView> createState() => _AdminCarListViewState();
}

class _AdminCarListViewState extends State<AdminCarListView> {
  late AdminVehicleViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminVehicleViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Car Models', style: TextStyle(fontWeight: FontWeight.bold)),
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
                if (service.loading && service.carList.cars.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.carList.cars.isEmpty) {
                  return const Center(child: Text('No cars found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchCars(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.carList.cars.length + (service.carList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.carList.cars.length) {
                        _viewModel.fetchCars(page: service.carList.pagination.currentPage + 1);
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                      }

                      final car = service.carList.cars[index];
                      return _buildCarCard(car);
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
            MaterialPageRoute(builder: (context) => const AdminCarFormView()),
          ).then((_) => _viewModel.fetchCars());
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
            controller: _viewModel.carSearchController,
            decoration: InputDecoration(
              hintText: 'Search cars...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: _viewModel.onCarSearchChanged,
          ),
          12.toHeight,
          Row(
            children: [
              Expanded(
                child: Consumer<AdminVehicleService>(
                  builder: (context, service, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _viewModel.brandFilter,
                          hint: const Text('All Brands'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<int>(value: null, child: Text('All Brands')),
                            ...service.brandList.brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
                          ],
                          onChanged: (v) => _viewModel.onBrandFilterChanged(v),
                        ),
                      ),
                    );
                  },
                ),
              ),
              12.toWidth,
              _buildSortButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return InkWell(
      onTap: () => _viewModel.toggleSort('name'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _viewModel.sortOrder == 'ASC' ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined,
          color: primaryColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCarCard(car) {
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
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: car.image != null
                    ? Image.network(car.image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, color: Colors.grey))
                    : const Icon(Icons.directions_car, color: Colors.grey),
              ),
              title: Text(car.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(car.brand?.name ?? 'No Brand', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
              trailing: PopupMenuButton<String>(
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'edit', child: Text('Edit Car')),
                  PopupMenuItem<String>(value: 'status', child: Text(car.status == 1 ? 'Deactivate' : 'Activate')),
                  const PopupMenuItem<String>(value: 'delete', child: Text('Delete Car', style: TextStyle(color: Colors.red))),
                ],
                onSelected: (val) {
                  if (val == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminCarFormView(car: car)),
                    ).then((_) => _viewModel.fetchCars());
                  } else if (val == 'status') {
                    _viewModel.toggleCarStatus(car);
                  } else if (val == 'delete') {
                    _showDeleteDialog(car);
                  }
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(car.status == 1 ? 'Active' : 'Inactive', car.status == 1 ? Colors.green : Colors.red),
                if (car.Year != null)
                  Text('Year: ${car.Year}', style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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

  void _showDeleteDialog(car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Car', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete ${car.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteCar(car.id);
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
