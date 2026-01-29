// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthrizeNetPay {
  static authorizeNetPay(
      BuildContext context, card, DateTime eDate, String amount, cCode,
      {orderId,
      inTesting = true,
      String? userId,
      String? userIp,
      Function? onTransactionFailed,
      Function? onTransactionApproved}) async {
    print('sending otpCode');
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST',
          Uri.parse(inTesting
              ? 'https://apitest.authorize.net/xml/v1/request.api'
              : 'https://authorize.net/xml/v1/request.api'));
      print({
        "cardNumber": "$card",
        "expirationDate": "${eDate.year}-${eDate.month}",
        "cardCode": "$cCode"
      });
      request.body = json.encode({
        "createTransactionRequest": {
          "merchantAuthentication": {
            "name": "568Yc9uV3",
            "transactionKey": "9tzGhhbEG57V367E"
          },
          "refId": "ddffds$orderId",
          "transactionRequest": {
            "transactionType": "authCaptureTransaction",
            "amount": amount,
            "payment": {
              "creditCard": {
                "cardNumber": "$card",
                "expirationDate": "${eDate.year}-${eDate.month}",
                "cardCode": "$cCode"
              }
            },
            "tax": {
              "amount": "0",
              "name": "level2 tax name",
              "description": "level2 tax"
            },
            "duty": {
              "amount": "0",
              "name": "duty name",
              "description": "duty description"
            },
            "shipping": {"amount": "0", "name": "", "description": ""},
            "customer": {"id": userId ?? "99999456654"},
            "customerIP": userIp ?? "192.168.1.1",
            "transactionSettings": {
              "setting": {"settingName": "nothing", "settingValue": "false"}
            },
            "userFields": {
              "userField": [
                {
                  "name": "MerchantDefinedFieldName1",
                  "value": "MerchantDefinedFieldValue1"
                },
                {"name": "favorite_color", "value": "blue"}
              ]
            },
            "processingOptions": {"isSubsequentAuth": "true"},
            "subsequentAuthInformation": {
              "originalNetworkTransId": "d7dfas$orderId",
              "originalAuthAmount": amount,
              "reason": "resubmission"
            },
            "authorizationIndicatorType": {"authorizationIndicator": "final"}
          }
        }
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final data = await response.stream.bytesToString();
      debugPrint(data.toString());
      debugPrint(response.statusCode.toString());
      if (data.contains('This transaction has been approved') &&
          onTransactionApproved != null) {
        debugPrint(data.toString());
        onTransactionApproved();
        return;
      }
      if (onTransactionFailed != null) {
        onTransactionFailed();
      }
    } on TimeoutException {
      if (onTransactionFailed != null) {
        onTransactionFailed();
      }
      LocalKeys.connectionTimeout.showToast();
    } catch (err) {
      if (onTransactionFailed != null) {
        onTransactionFailed();
      }
      "${LocalKeys.errorOccurred}: $err".showToast();
    }
  }
}
