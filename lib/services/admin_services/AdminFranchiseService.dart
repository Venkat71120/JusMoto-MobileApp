import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/admin_franchise_model.dart';
import '../../helper/extension/string_extension.dart';

class AdminFranchiseService extends ChangeNotifier {
  AdminFranchiseListModel _franchiseList = AdminFranchiseListModel.empty();
  AdminFranchiseListModel get franchiseList => _franchiseList;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchFranchises({
    int page = 1,
    String? search,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      String url = '${AppUrls.adminFranchisesUrl}?page=$page&limit=15';
      if (search != null && search.isNotEmpty) url += '&search=$search';

      final response = await NetworkApiServices().getApi(
        url,
        "Admin Franchises List",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        _franchiseList = AdminFranchiseListModel.fromJson(Map<String, dynamic>.from(response));
        debugPrint('✅ Admin Franchises fetched successfully');
      } else {
        debugPrint('❌ Failed to fetch Admin Franchises');
        "Failed to load franchise list".showToast();
      }
    } catch (e) {
      debugPrint('❌ Exception fetching Admin Franchises: $e');
      "Error: $e".showToast();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createFranchise(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().postApi(
        data,
        AppUrls.adminFranchisesUrl,
        "Create Franchise",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        "Franchise created successfully".showToast();
        return true;
      } else {
        "Failed to create franchise".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error creating franchise: $e');
      "Error: $e".showToast();
      return false;
    }
  }

  Future<bool> updateFranchise(int id, Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().putApi(
        data,
        '${AppUrls.adminFranchisesUrl}/$id',
        "Update Franchise",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        // Update local state for immediate feedback if possible
        if (data.containsKey('status')) {
           final index = _franchiseList.franchises.indexWhere((f) => f.id == id);
           if (index != -1) {
             _franchiseList.franchises[index] = _franchiseList.franchises[index].copyWith(
               status: data['status']
             );
             notifyListeners();
           }
        }
        "Franchise updated successfully".showToast();
        return true;
      } else {
        "Failed to update franchise".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating franchise: $e');
      "Error: $e".showToast();
      return false;
    }
  }

  Future<bool> deleteFranchise(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi(
        '${AppUrls.adminFranchisesUrl}/$id',
        "Delete Franchise",
        headers: acceptJsonAuthHeader,
      );

      if (response != null && response['success'] == true) {
        // Remove locally
        _franchiseList.franchises.removeWhere((f) => f.id == id);
        notifyListeners();
        "Franchise deleted successfully".showToast();
        return true;
      } else {
        "Failed to delete franchise".showToast();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting franchise: $e');
      "Error: $e".showToast();
      return false;
    }
  }
}
