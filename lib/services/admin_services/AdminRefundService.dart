import 'package:flutter/material.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../models/admin_models/AdminRefundModels.dart';
import '../../helper/extension/string_extension.dart';

class AdminRefundService extends ChangeNotifier {
  AdminRefundListModel _refundList = AdminRefundListModel.empty();
  AdminRefundListModel get refundList => _refundList;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchRefunds({int page = 1, String status = ''}) async {
    _loading = true;
    notifyListeners();
    try {
      String url = '${AppUrls.adminRefundedOrdersUrl}?page=$page&limit=15';
      if (status.isNotEmpty) url += '&status=$status';

      final response = await NetworkApiServices().getApi(url, "Admin Refund List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        final newList = AdminRefundListModel.fromJson(Map<String, dynamic>.from(response));
        if (page == 1) {
          _refundList = newList;
        } else {
          _refundList = AdminRefundListModel(
            data: [..._refundList.data, ...newList.data],
            pagination: newList.pagination,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching refunds: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRefundStatus(int id, int status) async {
    try {
      final response = await NetworkApiServices().putApi(
        {'status': status},
        '${AppUrls.adminRefundedOrdersUrl}/$id/status',
        "Update Refund Status",
        headers: acceptJsonAuthHeader,
      );
      if (response != null && response['success'] == true) {
        "Refund status updated".showToast();
        // Re-fetch current page for consistency
        fetchRefunds(page: _refundList.pagination?.page ?? 1);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error updating refund status: $e');
      return false;
    }
  }
}
