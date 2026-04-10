import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/AdminUserModels.dart';
import '../../helper/extension/string_extension.dart';

class AdminUserManagementService extends ChangeNotifier {
  AdminUserListModel _franchiseList = AdminUserListModel.empty();
  AdminUserListModel get franchiseList => _franchiseList;

  AdminUserListModel _userList = AdminUserListModel.empty();
  AdminUserListModel get userList => _userList;

  AdminUserListModel _staffList = AdminUserListModel.empty();
  AdminUserListModel get staffList => _staffList;

  List<dynamic> _roles = [];
  List<dynamic> get roles => _roles;

  bool _loading = false;
  bool get loading => _loading;

  String _getEndpoint(String type, int? id) {
    String base;
    switch (type) {
      case 'franchise': base = AppUrls.adminFranchisesUrl; break;
      case 'staff': base = AppUrls.adminStaffUrl; break;
      case 'user': base = AppUrls.adminUsersUrl; break;
      default: base = AppUrls.adminUsersUrl;
    }
    return id != null ? '$base/$id' : base;
  }

  Future<void> fetchFranchises({int page = 1}) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().getApi(
        '${AppUrls.adminFranchisesUrl}?page=$page&limit=15',
        "Admin Franchise List",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        _franchiseList = AdminUserListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching franchises: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers({int page = 1}) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().getApi(
        '${AppUrls.adminUsersUrl}?page=$page&limit=15',
        "Admin Users List",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        _userList = AdminUserListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching users: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStaff({int page = 1}) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().getApi(
        '${AppUrls.adminStaffUrl}?page=$page&limit=15',
        "Admin Staff List",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        _staffList = AdminUserListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching staff: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoles() async {
    try {
      final response = await NetworkApiServices().getApi(
        AppUrls.adminRolesUrl,
        "Admin Roles",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        _roles = response['data'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error fetching roles: $e');
    }
  }

  Future<bool> createFranchise(Map<String, dynamic> data) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().postApi(
        data,
        AppUrls.adminFranchisesUrl,
        "Create Franchise",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        "Franchise account created successfully".showToast();
        fetchFranchises();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating franchise: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserStatus(int id, String type, int currentStatus) async {
    final newStatus = currentStatus == 1 ? 0 : 1;
    try {
      final response = await NetworkApiServices().putApi(
        {'status': newStatus},
        _getEndpoint(type, id),
        "Update Status",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        "Status updated successfully".showToast();
        _refreshType(type);
        return true;
      }
      "Failed to update status".showToast();
      return false;
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
      return false;
    }
  }

  Future<bool> updateUserDetail(int id, String type, Map<String, dynamic> data) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().putApi(
        data,
        _getEndpoint(type, id),
        "Update Partner/Staff",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        "Details updated successfully".showToast();
        _refreshType(type);
        return true;
      }
      "Failed to update details".showToast();
      return false;
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int id, String type) async {
    try {
      final response = await NetworkApiServices().deleteApi(
        _getEndpoint(type, id),
        "Delete Account",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        "Account deleted successfully".showToast();
        _refreshType(type);
        return true;
      }
      "Failed to delete account".showToast();
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      return false;
    }
  }

  void _refreshType(String type) {
    if (type == 'franchise') fetchFranchises();
    if (type == 'staff') fetchStaff();
    if (type == 'user') fetchUsers();
  }
}
