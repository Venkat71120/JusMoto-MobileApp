import 'dart:async';
import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../customization.dart';
import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class RazorpayPayment extends StatelessWidget {
  final num amount;
  final apiKey;
  final apiSecret;
  final orderId;
  final userPhone;
  final userName;
  final userEmail;
  final onSuccess;
  final onFailed;

  RazorpayPayment({
    super.key,
    required this.amount,
    this.apiKey,
    this.apiSecret,
    this.orderId,
    this.userPhone,
    this.userName,
    this.userEmail,
    this.onSuccess,
    this.onFailed,
  });
  String? url;
  String? paymentID;
  final WebViewController _controller = WebViewController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NavigationPopIcon(onTap: () async {
          Alerts().paymentFailWarning(context, onFailed: onFailed);
        }),
      ),
      body: WillPopScope(
        onWillPop: () async {
          bool canGoBack = await _controller.canGoBack();
          if (canGoBack) {
            _controller.goBack();
            return false;
          }
          Alerts().paymentFailWarning(context, onFailed: onFailed);
          return false;
        },
        child: FutureBuilder(
            future: waitForIt(apiKey, apiSecret, orderId, userName, userEmail,
                userPhone, amount),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: SizedBox(height: 60, child: CustomPreloader())),
                  ],
                );
              }
              if (snapshot.hasData) {}
              if (snapshot.hasError) {
                print(snapshot.error);
              }
              _controller
                ..loadRequest(Uri.parse(url ?? ''))
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(NavigationDelegate(
                  onProgress: (int progress) {},
                  onPageStarted: (String url) async {
                    final uri = Uri.parse(url);
                    final response = await http.get(uri);
                    bool paySuccess = response.body.contains('status":"paid');
                    if (paySuccess) {
                      onSuccess();
                    }
                  },
                  onPageFinished: (String url) async {},
                  onWebResourceError: (WebResourceError error) {},
                  onNavigationRequest: (request) {
                    return NavigationDecision.navigate;
                  },
                ));
              return WebViewWidget(controller: _controller);
            }),
      ),
    );
  }

  Future waitForIt(apiKey, apiSecret, orderId, userName, userEmail, userPhone,
      num amount) async {
    final uri = Uri.parse('https://api.razorpay.com/v1/payment_links');
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';
    final header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": basicAuth,
    };
    final response = await http.post(uri,
        headers: header,
        body: jsonEncode({
          "amount": amount * 100,
          "currency": "INR",
          "accept_partial": false,
          "reference_id": orderId.toString(),
          "description": "$appLabel payment",
          "customer": {
            "name": userName,
            "contact": userPhone,
            "email": userEmail
          },
          "notes": {"policy_name": appLabel},
        }));
    print(response.body);
    if (response.statusCode == 200) {
      url = jsonDecode(response.body)['short_url'];
      paymentID = jsonDecode(response.body)['id'];
      print(url);
      return;
    }
    LocalKeys.loadingFailed.showToast();
    return 'failed';
  }
}
