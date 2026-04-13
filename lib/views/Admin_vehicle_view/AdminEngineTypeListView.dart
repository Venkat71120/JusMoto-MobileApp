import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminVehicleViewModel.dart';
import 'package:car_service/services/admin_services/AdminVehicleService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminEngineTypeListView extends StatefulWidget {
  const AdminEngineTypeListView({super.key});

  @override
  State<AdminEngineTypeListView> createState() => _AdminEngineTypeListViewState();
}

class _AdminEngineTypeListViewState extends State<AdminEngineTypeListView> {
  late AdminVehicleViewModel _viewModel;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = AdminVehicleViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initEngineTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Engine Types', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildAddInline(),
          Expanded(
            child: Consumer<AdminVehicleService>(
              builder: (context, service, child) {
                if (service.loading && service.engineTypeList.engineTypes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.engineTypeList.engineTypes.isEmpty) {
                  return const Center(child: Text('No engine types found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchEngineTypes(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.engineTypeList.engineTypes.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = service.engineTypeList.engineTypes[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        tileColor: Colors.white,
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('ID: #${item.id}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                              onPressed: () => _showEditDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              onPressed: () => _showDeleteDialog(item),
                            ),
                          ],
                        ),
                      );
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

  Widget _buildAddInline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'New engine type (e.g. V8)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          12.toWidth,
          ElevatedButton(
            onPressed: _addItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _addItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final service = Provider.of<AdminVehicleService>(context, listen: false);
    final success = await service.createEngineType({'name': name, 'status': '1'});
    if (success) {
      _nameController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showEditDialog(item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Engine Type'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                final service = Provider.of<AdminVehicleService>(context, listen: false);
                await service.updateEngineType(item.id, {'name': name});
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Engine Type', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _viewModel.deleteEngineType(item.id);
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
    _nameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }
}
