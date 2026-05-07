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

  AdminVariantListModel _variantList = AdminVariantListModel.empty();
  AdminVariantListModel get variantList => _variantList;

  AdminEngineTypeListModel _engineTypeList = AdminEngineTypeListModel.empty();
  AdminEngineTypeListModel get engineTypeList => _engineTypeList;

  AdminFuelTypeListModel _fuelTypeList = AdminFuelTypeListModel.empty();
  AdminFuelTypeListModel get fuelTypeList => _fuelTypeList;

  bool _loading = false;
  bool get loading => _loading;

  bool _fetchingMore = false;
  bool get fetchingMore => _fetchingMore;

  // --- Brands ---

  Future<int?> _uploadImage(File image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppUrls.adminMediaUploadUrl));
      request.headers.addAll(acceptJsonAuthHeader);
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await NetworkApiServices().postWithFileApi(request, "Upload Media");
      if (response != null && response['success'] == true) {
        final id = response['data']?['id'] as int?;
        debugPrint('✅ Media uploaded successfully, ID: $id');
        return id;
      } else {
        debugPrint('❌ Media upload failed: $response');
      }
    } catch (e) {
      debugPrint('❌ Error uploading media: $e');
    }
    return null;
  }

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
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      if (image != null) {
        final mediaId = await _uploadImage(image);
        if (mediaId != null) payload['image'] = mediaId;
      }

      final response = await NetworkApiServices().postApi(payload, AppUrls.adminBrandsUrl, "Create Brand", headers: acceptJsonAuthHeader);
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
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      if (image != null) {
        final mediaId = await _uploadImage(image);
        if (mediaId != null) payload['image'] = mediaId;
      }

      final response = await NetworkApiServices().putApi(payload, '${AppUrls.adminBrandsUrl}/$id', "Update Brand", headers: acceptJsonAuthHeader);
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
    if (page > 1) {
      _fetchingMore = true;
    } else {
      _loading = true;
    }
    notifyListeners();
    try {
      String url = '${AppUrls.adminCarsUrl}?page=$page&limit=15';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (brandId != null) url += '&brand_id=$brandId';
      if (sort != null) url += '&sort=$sort';
      if (order != null) url += '&order=$order';

      final response = await NetworkApiServices().getApi(url, "Admin Cars List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        debugPrint('🚗 Raw Car Data: ${response['data']?.take(1)}'); // Print first car for debug
        final newModel = AdminCarListModel.fromJson(Map<String, dynamic>.from(response));
        if (page > 1) {
          _carList.cars.addAll(newModel.cars);
          _carList = AdminCarListModel(
            cars: _carList.cars,
            pagination: newModel.pagination,
          );
        } else {
          _carList = newModel;
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching cars: $e');
    } finally {
      _loading = false;
      _fetchingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createCar(Map<String, String> data, File? image) async {
    try {
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      if (image != null) {
        final mediaId = await _uploadImage(image);
        if (mediaId != null) payload['image'] = mediaId;
      }

      final response = await NetworkApiServices().postApi(payload, AppUrls.adminCarsUrl, "Create Car", headers: acceptJsonAuthHeader);
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
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      if (image != null) {
        final mediaId = await _uploadImage(image);
        if (mediaId != null) payload['image'] = mediaId;
      }

      final response = await NetworkApiServices().putApi(payload, '${AppUrls.adminCarsUrl}/$id', "Update Car", headers: acceptJsonAuthHeader);
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

  // --- Variants ---

  Future<void> fetchVariants({int page = 1, int? carId}) async {
    if (page > 1) {
      _fetchingMore = true;
    } else {
      _loading = true;
    }
    notifyListeners();
    try {
      String url = '${AppUrls.adminVariantsUrl}?page=$page&limit=15';
      if (carId != null) url += '&car_id=$carId';

      final response = await NetworkApiServices().getApi(url, "Admin Variants List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        final newModel = AdminVariantListModel.fromJson(Map<String, dynamic>.from(response));
        if (page > 1) {
          _variantList.variants.addAll(newModel.variants);
          _variantList = AdminVariantListModel(
            variants: _variantList.variants,
            pagination: newModel.pagination,
          );
        } else {
          _variantList = newModel;
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching variants: $e');
    } finally {
      _loading = false;
      _fetchingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createVariant(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().postApi(data, AppUrls.adminVariantsUrl, "Create Variant", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Variant created successfully".showToast();
        fetchVariants();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating variant: $e');
      return false;
    }
  }

  Future<bool> updateVariant(int id, Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().putApi(data, '${AppUrls.adminVariantsUrl}/$id', "Update Variant", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Variant updated successfully".showToast();
        fetchVariants();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating variant: $e');
      return false;
    }
  }

  Future<bool> deleteVariant(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminVariantsUrl}/$id', "Delete Variant", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _variantList.variants.removeWhere((v) => v.id == id);
        notifyListeners();
        "Variant deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting variant: $e');
      return false;
    }
  }

  // --- Engine Types ---

  Future<void> fetchEngineTypes({int page = 1}) async {
    if (page > 1) {
      _fetchingMore = true;
    } else {
      _loading = true;
    }
    notifyListeners();
    try {
      String url = '${AppUrls.adminEngineTypesUrl}?page=$page&limit=100';
      final response = await NetworkApiServices().getApi(url, "Admin Engine Types List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        final newModel = AdminEngineTypeListModel.fromJson(Map<String, dynamic>.from(response));
        if (page > 1) {
          _engineTypeList.engineTypes.addAll(newModel.engineTypes);
          _engineTypeList = AdminEngineTypeListModel(
            engineTypes: _engineTypeList.engineTypes,
            pagination: newModel.pagination,
          );
        } else {
          _engineTypeList = newModel;
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching engine types: $e');
    } finally {
      _loading = false;
      _fetchingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createEngineType(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().postApi(data, AppUrls.adminEngineTypesUrl, "Create Engine Type", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Engine Type created successfully".showToast();
        fetchEngineTypes();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating engine type: $e');
      return false;
    }
  }

  Future<bool> updateEngineType(int id, Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().putApi(data, '${AppUrls.adminEngineTypesUrl}/$id', "Update Engine Type", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Engine Type updated successfully".showToast();
        fetchEngineTypes();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating engine type: $e');
      return false;
    }
  }

  Future<bool> deleteEngineType(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminEngineTypesUrl}/$id', "Delete Engine Type", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _engineTypeList.engineTypes.removeWhere((e) => e.id == id);
        notifyListeners();
        "Engine Type deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting engine type: $e');
      return false;
    }
  }

  // --- Fuel Types ---

  Future<void> fetchFuelTypes({int page = 1}) async {
    if (page > 1) {
      _fetchingMore = true;
    } else {
      _loading = true;
    }
    notifyListeners();
    try {
      String url = '${AppUrls.adminFuelTypesUrl}?page=$page&limit=100';
      final response = await NetworkApiServices().getApi(url, "Admin Fuel Types List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        final newModel = AdminFuelTypeListModel.fromJson(Map<String, dynamic>.from(response));
        if (page > 1) {
          _fuelTypeList.fuelTypes.addAll(newModel.fuelTypes);
          _fuelTypeList = AdminFuelTypeListModel(
            fuelTypes: _fuelTypeList.fuelTypes,
            pagination: newModel.pagination,
          );
        } else {
          _fuelTypeList = newModel;
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching fuel types: $e');
    } finally {
      _loading = false;
      _fetchingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createFuelType(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().postApi(data, AppUrls.adminFuelTypesUrl, "Create Fuel Type", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Fuel Type created successfully".showToast();
        fetchFuelTypes();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating fuel type: $e');
      return false;
    }
  }

  Future<bool> updateFuelType(int id, Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().putApi(data, '${AppUrls.adminFuelTypesUrl}/$id', "Update Fuel Type", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Fuel Type updated successfully".showToast();
        fetchFuelTypes();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating fuel type: $e');
      return false;
    }
  }

  Future<bool> deleteFuelType(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminFuelTypesUrl}/$id', "Delete Fuel Type", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _fuelTypeList.fuelTypes.removeWhere((f) => f.id == id);
        notifyListeners();
        "Fuel Type deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting fuel type: $e');
      return false;
    }
  }
}
