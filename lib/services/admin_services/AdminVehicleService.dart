import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/admin_vehicle_models.dart';
import '../../helper/extension/string_extension.dart';

class AdminVehicleService extends ChangeNotifier {
  AdminBrandListModel _brandList = AdminBrandListModel.empty();
  AdminBrandListModel get brandList => _brandList;

  AdminCarListModel _carList = AdminCarListModel.empty();
  AdminCarListModel get carList => _carList;

  bool _loading = false;
  bool get loading => _loading;

  // --- Brands ---

  Future<void> fetchBrands({int page = 1, String? search}) async {
    _loading = true;
    notifyListeners();
    try {
      String url = '${AppUrls.adminBrandsUrl}?page=$page&limit=100'; // Higher limit for brands
      if (search != null && search.isNotEmpty) url += '&search=$search';

      final response = await NetworkApiServices().getApi(url, "Admin Brands List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _brandList = AdminBrandListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching brands: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createBrand(Map<String, String> data, File? image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppUrls.adminBrandsUrl));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Create Brand");
      if (response != null && response['success'] == true) {
        "Brand created successfully".showToast();
        fetchBrands();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating brand: $e');
      return false;
    }
  }

  Future<bool> updateBrand(int id, Map<String, String> data, File? image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${AppUrls.adminBrandsUrl}/$id'));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields['_method'] = 'PUT';
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Update Brand");
      if (response != null && response['success'] == true) {
        "Brand updated successfully".showToast();
        fetchBrands();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating brand: $e');
      return false;
    }
  }

  Future<bool> deleteBrand(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminBrandsUrl}/$id', "Delete Brand", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _brandList.brands.removeWhere((b) => b.id == id);
        notifyListeners();
        "Brand deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting brand: $e');
      return false;
    }
  }

  // --- Cars ---

  Future<void> fetchCars({int page = 1, String? search, int? brandId, String? sort, String? order}) async {
    _loading = true;
    notifyListeners();
    try {
      String url = '${AppUrls.adminCarsUrl}?page=$page&limit=15';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (brandId != null) url += '&brand_id=$brandId';
      if (sort != null) url += '&sort=$sort';
      if (order != null) url += '&order=$order';

      final response = await NetworkApiServices().getApi(url, "Admin Cars List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _carList = AdminCarListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching cars: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createCar(Map<String, String> data, File? image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppUrls.adminCarsUrl));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Create Car");
      if (response != null && response['success'] == true) {
        "Car created successfully".showToast();
        fetchCars();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating car: $e');
      return false;
    }
  }

  Future<bool> updateCar(int id, Map<String, String> data, File? image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${AppUrls.adminCarsUrl}/$id'));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields['_method'] = 'PUT';
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Update Car");
      if (response != null && response['success'] == true) {
        "Car updated successfully".showToast();
        fetchCars();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating car: $e');
      return false;
    }
  }

  Future<bool> deleteCar(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminCarsUrl}/$id', "Delete Car", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _carList.cars.removeWhere((c) => c.id == id);
        notifyListeners();
        "Car deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting car: $e');
      return false;
    }
  }
}
