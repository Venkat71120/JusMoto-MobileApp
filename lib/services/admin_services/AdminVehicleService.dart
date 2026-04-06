import 'package:flutter/material.dart';
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

  Future<bool> createBrand(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().postApi(data, AppUrls.adminBrandsUrl, "Create Brand", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Brand created successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating brand: $e');
      return false;
    }
  }

  Future<bool> updateBrand(int id, Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().putApi(data, '${AppUrls.adminBrandsUrl}/$id', "Update Brand", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Brand updated successfully".showToast();
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

  Future<bool> createCar(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().postApi(data, AppUrls.adminCarsUrl, "Create Car", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Car created successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating car: $e');
      return false;
    }
  }

  Future<bool> updateCar(int id, Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().putApi(data, '${AppUrls.adminCarsUrl}/$id', "Update Car", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Car updated successfully".showToast();
        // Local update for status
        if (data.containsKey('status')) {
          final index = _carList.cars.indexWhere((c) => c.id == id);
          if (index != -1) {
            _carList.cars[index] = _carList.cars[index].copyWith(status: data['status']);
            notifyListeners();
          }
        }
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
