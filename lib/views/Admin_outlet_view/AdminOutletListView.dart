import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminOutletViewModel.dart';
import 'package:car_service/services/admin_services/AdminOutletService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminOutletFormView.dart';

class AdminOutletListView extends StatefulWidget {
  const AdminOutletListView({super.key});

  @override
  State<AdminOutletListView> createState() => _AdminOutletListViewState();
}

class _AdminOutletListViewState extends State<AdminOutletListView> {
  late AdminOutletViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminOutletViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initOutlets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Outlet Locations', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<AdminOutletService>(
        builder: (context, service, child) {
          if (service.loading && service.outletList.outlets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.outletList.outlets.isEmpty) {
            return const Center(child: Text('No outlets found'));
          }

          return RefreshIndicator(
            onRefresh: () async => _viewModel.initOutlets(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: service.outletList.outlets.length,
              itemBuilder: (context, index) {
                final outlet = service.outletList.outlets[index];
                return _buildOutletCard(outlet);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminOutletFormView()),
          ).then((_) => _viewModel.initOutlets());
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOutletCard(outlet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on, color: primaryColor),
            ),
            title: Text(outlet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(outlet.address, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 4),
                if (outlet.postCode != null)
                  Text('Post Code: ${outlet.postCode}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                if (outlet.latitude != null && outlet.longitude != null)
                  Text('Coords: ${outlet.latitude}, ${outlet.longitude}', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontStyle: FontStyle.italic)),
              ],
            ),
            trailing: _buildStatusToggle(outlet),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminOutletFormView(outlet: outlet)),
                    ).then((_) => _viewModel.initOutlets());
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(outlet),
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(outlet) {
    return InkWell(
      onTap: () => _viewModel.toggleStatus(outlet),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: outlet.status == 1 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          outlet.status == 1 ? 'Active' : 'Inactive',
          style: TextStyle(color: outlet.status == 1 ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showDeleteDialog(outlet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Outlet', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete "${outlet.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteOutlet(outlet.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
