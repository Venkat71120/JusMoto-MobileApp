import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/AdminReviewModels.dart';
import '../../helper/extension/string_extension.dart';

class AdminReviewService extends ChangeNotifier {
  AdminReviewListModel _reviewList = AdminReviewListModel.empty();
  AdminReviewListModel get reviewList => _reviewList;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchReviews({int page = 1, String? status}) async {
    _loading = true;
    notifyListeners();
    try {
      String url = '${AppUrls.adminReviewsUrl}?page=$page&limit=15';
      if (status != null && status.isNotEmpty) url += '&status=$status';

      final response = await NetworkApiServices().getApi(url, "Admin Reviews List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _reviewList = AdminReviewListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching reviews: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(int id, String status) async {
    try {
      final response = await NetworkApiServices().putApi(
        {'status': status}, 
        '${AppUrls.adminReviewsUrl}/$id', 
        "Update Review Status", 
        headers: acceptJsonAuthHeader
      );
      
      if (response != null && response['success'] == true) {
        // Optimistic local update
        final index = _reviewList.reviews.indexWhere((r) => r.id == id);
        if (index != -1) {
          _reviewList.reviews[index] = _reviewList.reviews[index].copyWith(status: status);
          notifyListeners();
          "Review marked as $status".showToast();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating review status: $e');
      return false;
    }
  }

  Future<bool> deleteReview(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminReviewsUrl}/$id', "Delete Review", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _reviewList.reviews.removeWhere((r) => r.id == id);
        notifyListeners();
        "Review deleted successfully".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting review: $e');
      return false;
    }
  }
}
