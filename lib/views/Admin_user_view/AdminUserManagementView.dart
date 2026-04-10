import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminUserManagementViewModel.dart';
import 'package:car_service/services/admin_services/AdminUserManagementService.dart';
import 'package:car_service/views/Admin_user_view/AdminFranchiseFormView.dart';
import 'package:car_service/views/Admin_user_view/AdminUserEditFormView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminUserManagementView extends StatefulWidget {
  const AdminUserManagementView({super.key});

  @override
  State<AdminUserManagementView> createState() => _AdminUserManagementViewState();
}

class _AdminUserManagementViewState extends State<AdminUserManagementView> with SingleTickerProviderStateMixin {
  late AdminUserManagementViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModel = AdminUserManagementViewModel(context);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadCurrentTab();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentTab();
    });
  }

  void _loadCurrentTab() {
    if (_tabController.index == 0) _viewModel.initFranchises();
    if (_tabController.index == 1) _viewModel.initUsers();
    if (_tabController.index == 2) _viewModel.initStaff();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Ecosystem Management', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'Franchises'),
            Tab(text: 'Global Users'),
            Tab(text: 'Staff'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFranchiseTab(),
          _buildUserTab(),
          _buildStaffTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0 
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminFranchiseFormView())),
            backgroundColor: primaryColor,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Franchise', style: TextStyle(color: Colors.white)),
          )
        : null,
    );
  }

  Widget _buildFranchiseTab() {
    return Consumer<AdminUserManagementService>(
      builder: (context, service, child) {
        if (service.loading && service.franchiseList.data.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildUserList(service.franchiseList.data, 'franchise');
      },
    );
  }

  Widget _buildUserTab() {
    return Consumer<AdminUserManagementService>(
      builder: (context, service, child) {
        if (service.loading && service.userList.data.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildUserList(service.userList.data, 'user');
      },
    );
  }

  Widget _buildStaffTab() {
    return Consumer<AdminUserManagementService>(
      builder: (context, service, child) {
        if (service.loading && service.staffList.data.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildUserList(service.staffList.data, 'staff');
      },
    );
  }

  Widget _buildUserList(List users, String type) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No $type partners found', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user, type);
      },
    );
  }

  Widget _buildUserCard(user, String type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(type).withOpacity(0.1),
          child: Icon(_getTypeIcon(type), color: _getTypeColor(type), size: 20),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (user.phone != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(user.phone!, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
            if (user.outletName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 10, color: primaryColor.withOpacity(0.7)),
                  4.toWidth,
                  Text(user.outletName!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(user.status),
                if (user.role != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(user.role!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
              ],
            ),
            if (type != 'user') ...[
              const SizedBox(width: 8),
              _buildActionMenu(user, type),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(user, String type) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      onSelected: (val) {
        if (val == 'edit') {
           Navigator.push(context, MaterialPageRoute(builder: (context) => AdminUserEditFormView(user: user, type: type)));
        } else if (val == 'status') {
          _viewModel.toggleStatus(user, type);
        } else if (val == 'delete') {
          _showDeleteConfirm(user, type);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit Details')])),
        PopupMenuItem(value: 'status', child: Row(children: [Icon(user.status == 1 ? Icons.block : Icons.check_circle, size: 18), const SizedBox(width: 8), Text(user.status == 1 ? 'Deactivate' : 'Activate')])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete Account', style: TextStyle(color: Colors.red))])),
      ],
    );
  }

  void _showDeleteConfirm(user, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteAccount(user, type);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    bool isActive = status == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'franchise': return Icons.business_center;
      case 'staff': return Icons.engineering;
      default: return Icons.person;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'franchise': return Colors.indigo;
      case 'staff': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
