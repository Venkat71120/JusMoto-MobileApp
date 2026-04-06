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

  bool _loading = false;
  bool get loading => _loading;

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
}
