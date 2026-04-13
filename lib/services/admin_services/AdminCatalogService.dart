import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/admin_catalog_models.dart';
import '../../helper/extension/string_extension.dart';

class AdminCatalogService extends ChangeNotifier {
  AdminCategoryListModel _categoryList = AdminCategoryListModel.empty();
  AdminCategoryListModel get categoryList => _categoryList;

  AdminServiceListModel _serviceList = AdminServiceListModel.empty();
  AdminServiceListModel get serviceList => _serviceList;

  bool _loading = false;
  bool get loading => _loading;

  // --- Categories ---

  Future<void> fetchCategories({int page = 1, String? search}) async {
    _loading = true;
    notifyListeners();
    try {
      String url = '${AppUrls.adminCategoriesUrl}?page=$page&limit=15';
      if (search != null && search.isNotEmpty) url += '&search=$search';

      final response = await NetworkApiServices().getApi(url, "Admin Categories List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _categoryList = AdminCategoryListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory(Map<String, String> data, File? image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppUrls.adminCategoriesUrl));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Create Category");
      if (response != null && response['success'] == true) {
        "Category created successfully".showToast();
        fetchCategories();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating category: $e');
      return false;
    }
  }

  Future<bool> updateCategory(int id, Map<String, String> data, File? image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${AppUrls.adminCategoriesUrl}/$id'));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields['_method'] = 'PUT'; // Laravel/Node strategy for multipart PUT
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Update Category");
      if (response != null && response['success'] == true) {
        "Category updated successfully".showToast();
        fetchCategories();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminCategoriesUrl}/$id', "Delete Category", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _categoryList.categories.removeWhere((c) => c.id == id);
        notifyListeners();
        "Category deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting category: $e');
      return false;
    }
  }

  // --- Services / Products ---

  Future<void> fetchServices({int page = 1, String? search, int type = 0, String? status, String? isFeatured}) async {
    _loading = true;
    notifyListeners();
    try {
      String url = '${AppUrls.adminServicesUrl}?page=$page&limit=15&type=$type';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (status != null && status.isNotEmpty) url += '&status=$status';
      if (isFeatured != null && isFeatured.isNotEmpty) url += '&is_featured=$isFeatured';

      final response = await NetworkApiServices().getApi(url, "Admin Services List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _serviceList = AdminServiceListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching services: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createService(Map<String, String> data, File? image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppUrls.adminServicesUrl));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Create Service");
      if (response != null && response['success'] == true) {
        "Item created successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating service: $e');
      return false;
    }
  }

  Future<bool> updateService(int id, Map<String, String> data, File? image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${AppUrls.adminServicesUrl}/$id'));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields['_method'] = 'PUT';
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Update Service/Product");
      if (response != null && response['success'] == true) {
        "Item updated successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating service: $e');
      return false;
    }
  }

  Future<bool> deleteService(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminServicesUrl}/$id', "Delete Service", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _serviceList.services.removeWhere((s) => s.id == id);
        notifyListeners();
        "Item deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting service: $e');
      return false;
    }
  }

  // --- Toggle Endpoints (Status & Featured) ---

  Future<bool> toggleServiceStatus(int id) async {
    try {
      // The web app uses a specific endpoint: /admin/services/:id/status
      final response = await NetworkApiServices().putApi({}, '${AppUrls.adminServicesUrl}/$id/status', "Toggle Service Status", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        final index = _serviceList.services.indexWhere((s) => s.id == id);
        if (index != -1) {
          _serviceList.services[index] = _serviceList.services[index].copyWith(status: _serviceList.services[index].status == 1 ? 0 : 1);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error toggling status: $e');
      return false;
    }
  }

  Future<bool> toggleServiceFeatured(int id) async {
    try {
      // The web app uses a specific endpoint: /admin/services/:id/featured
      final response = await NetworkApiServices().putApi({}, '${AppUrls.adminServicesUrl}/$id/featured', "Toggle Service Featured", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        final index = _serviceList.services.indexWhere((s) => s.id == id);
        if (index != -1) {
          _serviceList.services[index] = _serviceList.services[index].copyWith(isFeatured: _serviceList.services[index].isFeatured == 1 ? 0 : 1);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error toggling featured: $e');
      return false;
    }
  }
}
