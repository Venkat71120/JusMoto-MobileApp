import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/models/service/admin_staff_list_model.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';

class AdminStaffListService with ChangeNotifier {
  AdminStaffListModel? _adminStaffListModel;
  AdminStaffListModel get adminStaffListModel =>
      _adminStaffListModel ?? AdminStaffListModel(staffs: []);

  bool get shouldAutoFetch => _adminStaffListModel?.staffs == null;

  fetchStaffList() async {
    var url = "${AppUrls.staffListUrl}?admin_id=1";

    try {
      final responseData = await NetworkApiServices().getApi(
          url, LocalKeys.serviceDetails,
          headers: acceptJsonAuthHeader, timeoutSeconds: 20);

      if (responseData != null) {
        _adminStaffListModel = AdminStaffListModel.fromJson(responseData);
      } else {
        _adminStaffListModel = AdminStaffListModel(staffs: []);
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}
