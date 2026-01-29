import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:car_service/customization.dart';
import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../data/network/network_api_services.dart';
import '../profile_services/profile_info_service.dart';

class HireProviderFromOfferService with ChangeNotifier {
  num totalAmount = 0;
  dynamic orderId;

  tryPlacingOrder(offerId, jobId, gateway, File? file) async {
    var url = AppUrls.hireProviderUrl;
    var data = {
      'job_offer_id': offerId.toString(),
      'job_post_id': jobId.toString(),
      'selected_payment_gateway': gateway.toString()
    };
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll(data);

    if (gateway == "manual_payment" && file != null) {
      request.files.add(
          await http.MultipartFile.fromPath('manual_payment_image', file.path));
    }
    log(jsonEncode(data));
    request.headers.addAll(acceptJsonAuthHeader);
    final responseData = await NetworkApiServices()
        .postWithFileApi(request, LocalKeys.payAndConfirmOrder);

    if (responseData != null) {
      totalAmount = responseData["total_amount"].toString().tryToParse;
      orderId = responseData["order_id"];
      return true;
    }
  }

  updatePayment(BuildContext context, {dynamic id}) async {
    var url = AppUrls.orderPaymentUpdateUrl;
    if ((orderId ?? id) == null) {
      LocalKeys.orderNotFound.showToast();
      return;
    }
    final pi = Provider.of<ProfileInfoService>(context, listen: false);
    var data = {'order_id': (id ?? orderId).toString()};
    debugPrint(data.toString());
    debugPrint(pi.profileInfoModel.userDetails?.email.toString());
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $getToken',
      "X-HMAC": (pi.profileInfoModel.userDetails?.email ?? "")
          .toHmac(secret: paymentUpdateKey),
    };
    final responseData = await NetworkApiServices()
        .postApi(data, url, LocalKeys.payAndConfirmOrder, headers: headers);

    if (responseData != null) {
      return true;
    }
  }

  void reset() {
    totalAmount = 0;
    orderId = null;
  }
}

/* services dummy

{
    "all_services": [
        {
            "service_id": "17",
            "staff_id": "1",
            "location_id": 1,
            "date": "2024-08-30",
            "schedule": "10:00AM - 1:00PM",
            "order_note": "Test Order notes data"
        },
        {
            "service_id": "20",
            "staff_id": "4",
            "location_id": 3,
            "date": "2024-08-30",
            "schedule": "10:00AM - 1:00PM",
            "order_note": "Test Order notes data"
        }
    ]
}

*/