import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminFranchiseViewModel.dart';
import 'package:car_service/services/admin_services/AdminFranchiseService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminFranchiseFormView.dart';

class AdminFranchiseListView extends StatefulWidget {
  const AdminFranchiseListView({super.key});

  @override
  State<AdminFranchiseListView> createState() => _AdminFranchiseListViewState();
}

class _AdminFranchiseListViewState extends State<AdminFranchiseListView> {
  late AdminFranchiseViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminFranchiseViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Franchise Partners', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<AdminFranchiseService>(
              builder: (context, service, child) {
                if (service.loading && service.franchiseList.franchises.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.franchiseList.franchises.isEmpty) {
                  return const Center(child: Text('No franchise partners found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchFranchises(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.franchiseList.franchises.length + (service.franchiseList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.franchiseList.franchises.length) {
                        _viewModel.fetchFranchises(page: service.franchiseList.pagination.currentPage + 1);
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                      }

                      final franchise = service.franchiseList.franchises[index];
                      return _buildFranchiseCard(franchise);
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
            MaterialPageRoute(builder: (context) => const AdminFranchiseFormView()),
          ).then((_) => _viewModel.fetchFranchises());
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
            controller: _viewModel.searchController,
            decoration: InputDecoration(
              hintText: 'Search franchises...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: _viewModel.onSearchChanged,
          ),
          if (_viewModel.searchController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _FilterChip(label: 'Search: ${_viewModel.searchController.text}', onClear: () {
                   _viewModel.searchController.clear();
                   _viewModel.fetchFranchises();
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFranchiseCard(franchise) {
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
              leading: CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Text(
                  franchise.name.isNotEmpty ? franchise.name[0] : '?',
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(franchise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(franchise.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              trailing: PopupMenuButton<String>(
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: const Text('Edit Partner'),
                  ),
                  PopupMenuItem<String>(
                    value: 'status',
                    child: Text(franchise.status == 1 ? 'Mark Inactive' : 'Mark Active'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete Partner', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminFranchiseFormView(franchise: franchise)),
                    ).then((_) => _viewModel.fetchFranchises());
                  } else if (val == 'status') {
                    _showStatusDialog(franchise);
                  } else if (val == 'delete') {
                    _showDeleteDialog(franchise);
                  }
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(
                  franchise.status == 1 ? 'Active' : 'Inactive',
                  franchise.status == 1 ? Colors.green : Colors.red,
                ),
                if (franchise.outlet != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Outlet: ${franchise.outlet!.name}',
                        style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                Text(
                  'Created: ${franchise.createdAt.split('T')[0]}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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

  void _showStatusDialog(franchise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Text('Are you sure you want to change the status for ${franchise.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.toggleFranchiseStatus(franchise);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(franchise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Franchise', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete ${franchise.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteFranchise(franchise.id);
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
