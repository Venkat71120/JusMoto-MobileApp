import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/AdminOutletModels.dart';
import '../../helper/extension/string_extension.dart';

class AdminOutletService extends ChangeNotifier {
  AdminOutletListModel _outletList = AdminOutletListModel.empty();
  AdminOutletListModel get outletList => _outletList;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchOutlets() async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().getApi(AppUrls.adminOutletLocationsUrl, "Admin Outlets List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _outletList = AdminOutletListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching outlets: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createOutlet(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().postApi(data, AppUrls.adminOutletLocationsUrl, "Create Outlet", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Outlet created successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating outlet: $e');
      return false;
    }
  }

  Future<bool> updateOutlet(int id, Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().putApi(data, '${AppUrls.adminOutletLocationsUrl}/$id', "Update Outlet", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Outlet updated successfully".showToast();
        // Local update
        final index = _outletList.outlets.indexWhere((o) => o.id == id);
        if (index != -1 && data.containsKey('status')) {
          _outletList.outlets[index] = _outletList.outlets[index].copyWith(status: data['status']);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating outlet: $e');
      return false;
    }
  }

  Future<bool> deleteOutlet(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminOutletLocationsUrl}/$id', "Delete Outlet", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _outletList.outlets.removeWhere((o) => o.id == id);
        notifyListeners();
        "Outlet deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting outlet: $e');
      return false;
    }
  }
}
