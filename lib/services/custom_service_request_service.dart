import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../data/network/network_api_services.dart';
import '../helper/app_urls.dart';
import '../helper/constant_helper.dart';
import '../models/custom_service_request_model.dart';

class CustomServiceRequestService with ChangeNotifier {
  CustomServiceRequestListModel _listModel =
      CustomServiceRequestListModel.empty();
  bool _isLoading = false;
  bool _isSubmitting = false;

  CustomServiceRequestListModel get listModel => _listModel;
  List<CustomServiceRequest> get requests => _listModel.requests;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get shouldAutoFetch => _listModel.requests.isEmpty && !_isLoading;

  /// Create a new custom service request
  Future<bool> createRequest({required String description}) async {
    _isSubmitting = true;
    notifyListeners();

    final body = {
      'description': description,
    };

    final responseData = await NetworkApiServices().postApi(
      body,
      AppUrls.createCustomServiceRequestUrl,
      "Custom Service Request",
      headers: acceptJsonAuthHeader,
    );

    _isSubmitting = false;

    if (responseData != null &&
        (responseData['success'] == true || responseData['data'] != null)) {
      "Service request submitted successfully".showToast();
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  /// Fetch the list of user's custom service requests
  Future fetchRequests() async {
    _isLoading = true;

    final responseData = await NetworkApiServices().getApi(
      '${AppUrls.customServiceRequestsUrl}?page=1&limit=20',
      "Custom Service Requests",
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      _listModel = CustomServiceRequestListModel.fromJson(
          Map<String, dynamic>.from(responseData));
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _listModel = CustomServiceRequestListModel.empty();
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }
}
