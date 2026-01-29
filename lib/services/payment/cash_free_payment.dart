import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CashFreePayment {
  late BuildContext context;

  Future doPayment(
    BuildContext context,
    appId,
    secretKey,
    amount,
    id,
    userName,
    userPhone,
    userMail,
    onSuccess,
    onFailed, {
    testing = false,
  }) async {
    this.context = context;

    if (appId == null || secretKey == null) {
      LocalKeys.invalidDeveloperKeys.showToast();
      onFailed();
      return;
    }

    final url = Uri.parse(
      testing
          ? "https://cashfree.com/api/v2/cftoken/order"
          : "https://test.cashfree.com/api/v2/cftoken/order",
    );

    final response = await http.post(
      url,
      headers: {
        "x-client-id": appId as String,
        "x-client-secret": secretKey as String,
      },
      body: jsonEncode({
        "orderId": id,
        "orderAmount": amount.toStringAsFixed(2),
        "orderCurrency": "INR",
      }),
    );
    print(jsonDecode(response.body)['cftoken']);
    if (200 == 200) {
      Map<String, dynamic> inputParams = {
        "orderId": id,
        "orderAmount": amount.toStringAsFixed(2),
        "customerName": userName,
        "orderCurrency": "INR",
        "appId": appId,
        "customerPhone": userPhone,
        "customerEmail": userMail,
        "stage": testing ? "TEST" : "",
        "tokenData": jsonDecode(response.body)['cftoken'],
      };
    }
  }
}
