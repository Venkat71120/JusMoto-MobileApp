import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/admin_user_model.dart';
import '../../helper/extension/string_extension.dart';

class AdminUsersService extends ChangeNotifier {
  AdminUserListModel _userList = AdminUserListModel.empty();
  AdminUserListModel get userList => _userList;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchUsers({
    int page = 1,
    String? search,
    String? status,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      String url = '${AppUrls.adminUsersUrl}?page=$page&limit=15';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (status != null && status.isNotEmpty) url += '&status=$status';

      final response = await NetworkApiServices().getApi(
        url,
        "Admin Users List",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        _userList = AdminUserListModel.fromJson(Map<String, dynamic>.from(response));
        debugPrint('✅ Admin Users fetched successfully');
      } else {
        debugPrint('❌ Failed to fetch Admin Users');
        "Failed to load user list".showToast();
      }
    } catch (e) {
      debugPrint('❌ Exception fetching Admin Users: $e');
      "Error: $e".showToast();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleUserStatus(int userId, int newStatus) async {
    try {
      final response = await NetworkApiServices().putApi(
        {'status': newStatus},
        '${AppUrls.adminUsersUrl}/$userId/status',
        "Toggle User Status",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        // Update local state for immediate feedback
        final index = _userList.users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _userList.users[index] = _userList.users[index].copyWith(status: newStatus);
          notifyListeners();
        }
        "User status updated".showToast();
        return true;
      } else {
        "Failed to update user status".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error toggling user status: $e');
      "Error: $e".showToast();
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final response = await NetworkApiServices().deleteApi(
        '${AppUrls.adminUsersUrl}/$userId',
        "Delete User",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        "User deleted successfully".showToast();
        return true;
      } else {
        "Failed to delete user".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      "Error: $e".showToast();
      return false;
    }
  }
}
