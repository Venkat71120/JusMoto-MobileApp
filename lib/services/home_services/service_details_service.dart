import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/service/service_details_model.dart';

class ServiceDetailsService with ChangeNotifier {
  final Map<String, ServiceDetailsModel> _serviceDetailsModel = {};

  ServiceDetailsModel serviceDetailsModel(id) =>
      _serviceDetailsModel[id.toString()] ?? ServiceDetailsModel();

  String token = '';

  shouldAutoFetch(id) =>
      !_serviceDetailsModel.containsKey(id.toString()) || token.isInvalid;

  fetchServiceDetails(id, {refreshing = false}) async {
    var url = "${AppUrls.serviceDetailsUrl}/$id";
    token = getToken;

    try {
      final responseData = await NetworkApiServices().getApi(
        url,
        LocalKeys.serviceDetails,
        headers: acceptJsonAuthHeader,
        timeoutSeconds: 20,
      );

      if (responseData != null) {
        _serviceDetailsModel[id.toString()] = ServiceDetailsModel.fromJson(
          responseData,
        );
      } else {
        if (!refreshing) {
          _serviceDetailsModel.remove(id.toString());
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  void remove(id) {
    _serviceDetailsModel.remove(id.toString());
  }
}
