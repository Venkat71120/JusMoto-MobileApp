import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';

class PaypalServices {
  String domain = "https://api.sandbox.paypal.com"; // for sandbox mode
  String liveDomain = "https://api.paypal.com"; // for production mode

  Future<String> getAccessToken(
      BuildContext context, String clientId, String clientSecret,
      {testMode = false}) async {
    try {
      var client = BasicAuthClient(clientId, clientSecret);
      var response = await client.post(Uri.parse(
          '${testMode ? domain : liveDomain}/v1/oauth2/token?grant_type=client_credentials'));
      print(response.body);
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        return body["access_token"];
      }
      return "0";
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> createPaypalPayment(transactions, accessToken,
      {testMode = false}) async {
    print(transactions);
    var response = await http.post(
        Uri.parse("${testMode ? domain : liveDomain}/v1/payments/payment"),
        body: convert.jsonEncode(transactions),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer ' + accessToken
        });

    final body = convert.jsonDecode(response.body);
    print(body);
    if (response.statusCode == 201) {
      if (body["links"] != null && body["links"].length > 0) {
        List links = body["links"];

        String executeUrl = "";
        String approvalUrl = "";
        final item = links.firstWhere((o) => o["rel"] == "approval_url",
            orElse: () => null);
        if (item != null) {
          approvalUrl = item["href"];
        }
        final item1 =
            links.firstWhere((o) => o["rel"] == "execute", orElse: () => null);
        if (item1 != null) {
          executeUrl = item1["href"];
        }
        print('approval:$approvalUrl\nexecute:$executeUrl');
        return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
      }
      throw Exception("0");
    } else {
      return {};
    }
  }

  Future<String> executePayment(url, payerId, accessToken) async {
    try {
      var response = await http.post(Uri.parse(url),
          body: convert.jsonEncode({"payer_id": payerId}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);
      print(response.statusCode);
      print(body);
      if (response.statusCode == 200) {
        return body["id"];
      }
      return "0";
    } catch (e) {
      rethrow;
    }
  }
}
