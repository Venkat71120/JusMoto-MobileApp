import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminUserManagementService.dart';
import '../../models/admin_models/AdminUserModels.dart';

class AdminUserManagementViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminUserManagementViewModel(this.context);

  void initFranchises() {
    final service = Provider.of<AdminUserManagementService>(context, listen: false);
    service.fetchFranchises();
  }

  void initUsers() {
    final service = Provider.of<AdminUserManagementService>(context, listen: false);
    service.fetchUsers();
  }

  void initStaff() {
    final service = Provider.of<AdminUserManagementService>(context, listen: false);
    service.fetchStaff();
  }

  Future<void> createFranchise(Map<String, dynamic> data) async {
    final service = Provider.of<AdminUserManagementService>(context, listen: false);
    await service.createFranchise(data);
  }

  Future<void> toggleStatus(AdminBaseUserItem user, String type) async {
    final service = Provider.of<AdminUserManagementService>(context, listen: false);
    await service.updateUserStatus(user.id, type, user.status);
  }

  Future<void> updateAccount(AdminBaseUserItem user, String type, Map<String, dynamic> data) async {
    final service = Provider.of<AdminUserManagementService>(context, listen: false);
    await service.updateUserDetail(user.id, type, data);
  }

  Future<void> deleteAccount(AdminBaseUserItem user, String type) async {
    final service = Provider.of<AdminUserManagementService>(context, listen: false);
    await service.deleteUser(user.id, type);
  }
}
