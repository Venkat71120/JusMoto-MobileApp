import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminUsersViewModel.dart';
import 'package:car_service/services/admin_services/AdminUsersService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  late AdminUsersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminUsersViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Users Management', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<AdminUsersService>(
              builder: (context, service, child) {
                if (service.loading && service.userList.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.userList.users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchUsers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.userList.users.length + (service.userList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.userList.users.length) {
                        _viewModel.fetchUsers(page: service.userList.pagination.currentPage + 1);
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                      }

                      final user = service.userList.users[index];
                      return _buildUserCard(user);
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _viewModel.searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: _viewModel.onSearchChanged,
          ),
          12.toHeight,
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w600)),
              8.toWidth,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _viewModel.statusFilter.isEmpty ? null : _viewModel.statusFilter,
                      hint: const Text('All Status'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All Status')),
                        DropdownMenuItem(value: '1', child: Text('Active')),
                        DropdownMenuItem(value: '0', child: Text('Inactive')),
                      ],
                      onChanged: (val) {
                        _viewModel.onStatusFilterChanged(val);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(user) {
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
                backgroundColor: _getAvatarColor(user.id).withOpacity(0.1),
                child: Text(
                  user.firstName.isNotEmpty ? user.firstName[0] : '?',
                  style: TextStyle(color: _getAvatarColor(user.id), fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  if (user.phone != null) Text(user.phone!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
              trailing: PopupMenuButton<String>(
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'status',
                    child: Text(user.status == 1 ? 'Mark Inactive' : 'Mark Active'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete User', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'status') {
                    _showStatusDialog(user);
                  } else if (val == 'delete') {
                    _showDeleteDialog(user);
                  }
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(
                  user.status == 1 ? 'Active' : 'Inactive',
                  user.status == 1 ? Colors.green : Colors.red,
                ),
                _buildBadge(
                  user.emailVerified ? 'Verified' : 'Unverified',
                  user.emailVerified ? Colors.blue : Colors.orange,
                ),
                Text(
                  'Joined: ${user.createdAt.split('T')[0]}',
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

  void _showStatusDialog(user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Text('Are you sure you want to change the status for ${user.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.toggleUserStatus(user.id, user.status);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteUser(user.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(int id) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    return colors[id % colors.length];
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
