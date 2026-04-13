import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/admin_marketing_models.dart';
import '../../helper/extension/string_extension.dart';

class AdminMarketingService extends ChangeNotifier {
  AdminCouponListModel _couponList = AdminCouponListModel.empty();
  AdminCouponListModel get couponList => _couponList;

  AdminOfferListModel _offerList = AdminOfferListModel.empty();
  AdminOfferListModel get offerList => _offerList;

  bool _loading = false;
  bool get loading => _loading;

  // --- Coupons ---

  Future<void> fetchCoupons() async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().getApi(AppUrls.adminCouponsUrl, "Admin Coupons List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _couponList = AdminCouponListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching coupons: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createCoupon(Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().postApi(data, AppUrls.adminCouponsUrl, "Create Coupon", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Coupon created successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating coupon: $e');
      return false;
    }
  }

  Future<bool> updateCoupon(int id, Map<String, dynamic> data) async {
    try {
      final response = await NetworkApiServices().putApi(data, '${AppUrls.adminCouponsUrl}/$id', "Update Coupon", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        "Coupon updated successfully".showToast();
        // Local update
        final index = _couponList.coupons.indexWhere((c) => c.id == id);
        if (index != -1 && data.containsKey('status')) {
          _couponList.coupons[index] = _couponList.coupons[index].copyWith(status: data['status']);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating coupon: $e');
      return false;
    }
  }

  Future<bool> deleteCoupon(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminCouponsUrl}/$id', "Delete Coupon", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _couponList.coupons.removeWhere((c) => c.id == id);
        notifyListeners();
        "Coupon deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting coupon: $e');
      return false;
    }
  }

  // --- Offers ---

  Future<void> fetchOffers() async {
    _loading = true;
    notifyListeners();
    try {
      final response = await NetworkApiServices().getApi(AppUrls.adminOffersUrl, "Admin Offers List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _offerList = AdminOfferListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching offers: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createOffer(Map<String, String> data, File? image, List<int> serviceIds) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppUrls.adminOffersUrl));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }
      
      // Add service IDs as indexed fields if needed, or comma separated string
      // Let's use service_ids[] or similar if required by backend
      for (int i = 0; i < serviceIds.length; i++) {
        request.fields['service_ids[$i]'] = serviceIds[i].toString();
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Create Offer");
      if (response != null && response['success'] == true) {
        "Offer created successfully".showToast();
        fetchOffers();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error creating offer: $e');
      return false;
    }
  }

  Future<bool> updateOffer(int id, Map<String, String> data, File? image, List<int> serviceIds) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${AppUrls.adminOffersUrl}/$id'));
      request.headers.addAll(acceptJsonAuthHeader);
      request.fields['_method'] = 'PUT';
      request.fields.addAll(data);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      for (int i = 0; i < serviceIds.length; i++) {
        request.fields['service_ids[$i]'] = serviceIds[i].toString();
      }

      final response = await NetworkApiServices().postWithFileApi(request, "Update Offer");
      if (response != null && response['success'] == true) {
        "Offer updated successfully".showToast();
        fetchOffers();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating offer: $e');
      return false;
    }
  }

  Future<bool> deleteOffer(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminOffersUrl}/$id', "Delete Offer", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _offerList.offers.removeWhere((o) => o.id == id);
        notifyListeners();
        "Offer deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting offer: $e');
      return false;
    }
  }
}
