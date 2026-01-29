import 'package:car_service/helper/app_urls.dart';
import 'package:flutter/material.dart';

import '../../data/network/network_api_services.dart';

class CancellationPolicyService {
  ValueNotifier<Map> cancellationData = ValueNotifier({});
  CancellationPolicyService._init();
  static CancellationPolicyService? _instance;
  static CancellationPolicyService get instance {
    _instance ??= CancellationPolicyService._init();
    return _instance!;
  }

  CancellationPolicyService._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  fetchCancellationPolicy() async {
    var url = AppUrls.cancellationPolicyUrl;

    final responseData = await NetworkApiServices().getApi(url, null);

    if (responseData != null) {
      cancellationData.value = responseData["cancel_policy"];
      return true;
    }
  }
}
