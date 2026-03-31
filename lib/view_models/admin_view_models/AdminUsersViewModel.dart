import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminUsersService.dart';

class AdminUsersViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminUsersViewModel(this.context);

  final TextEditingController searchController = TextEditingController();
  String _statusFilter = '';
  String get statusFilter => _statusFilter;

  Timer? _searchTimer;

  void init() {
    fetchUsers();
  }

  void fetchUsers({int page = 1}) {
    final service = Provider.of<AdminUsersService>(context, listen: false);
    service.fetchUsers(
      page: page,
      search: searchController.text,
      status: _statusFilter,
    );
  }

  void onSearchChanged(String value) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchUsers();
    });
  }

  void onStatusFilterChanged(String? value) {
    _statusFilter = value ?? '';
    notifyListeners();
    fetchUsers();
  }

  Future<void> toggleUserStatus(int userId, int currentStatus) async {
    final service = Provider.of<AdminUsersService>(context, listen: false);
    final success = await service.toggleUserStatus(userId, currentStatus == 1 ? 0 : 1);
    if (success) {
      fetchUsers(page: service.userList.pagination.currentPage);
    }
  }

  Future<void> deleteUser(int userId) async {
    final service = Provider.of<AdminUsersService>(context, listen: false);
    final success = await service.deleteUser(userId);
    if (success) {
      fetchUsers(page: service.userList.pagination.currentPage);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }
}
