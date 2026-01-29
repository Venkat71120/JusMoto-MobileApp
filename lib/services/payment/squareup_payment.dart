import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../customization.dart';
import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class SquareUpPayment extends StatelessWidget {
  final accessToken;
  final locationId;
  final orderId;
  final int amount;
  final currencyCode;
  final orderNote;
  final userEmail;
  final bool testing;
  final onSuccess;
  final onFailed;
  SquareUpPayment({
    super.key,
    this.accessToken,
    this.locationId,
    this.orderId,
    required this.amount,
    this.currencyCode,
    this.orderNote,
    this.userEmail,
    required this.testing,
    this.onSuccess,
    this.onFailed,
  });
  String? url;
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
            future: waitForIt(accessToken, locationId, orderId, amount,
                currencyCode, orderNote, userEmail, testing),
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
                    final response = await http.get(Uri.parse(url));
                    if (response.body.contains('"tenders_finalized":true')) {
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

  waitForIt(accessToken, locationId, orderId, int amount, currencyCode,
      orderNote, userEmail, bool testing) async {
    final url = Uri.parse(
        'https://connect.${testing ? "squareupsandbox" : "squareup"}.com/v2/online-checkout/payment-links');

    final header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": 'Bearer  $accessToken',
    };
    final response = await http.post(url,
        headers: header,
        body: jsonEncode({
          "description": "$appLabel payments",
          "idempotency_key": '$orderId',
          "quick_pay": {
            "location_id": locationId,
            "name": "$appLabel payments",
            "price_money": {"amount": amount, "currency": currencyCode}
          },
          "payment_note": orderNote,
          "pre_populated_data": {
            "buyer_email": userEmail,
          }
        }));
    print(response.body);
    if (response.statusCode == 200) {
      this.url = jsonDecode(response.body)['payment_link']['url'];
      print(this.url);
      return;
    }

    return true;
  }
}
