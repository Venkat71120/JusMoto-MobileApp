import 'dart:async';
import 'dart:convert';

import 'package:car_service/data/network/network_api_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../customization.dart';
import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class SitesWayPayment extends StatelessWidget {
  final onSuccess;
  final onFailed;
  final String amount;
  final brandId;
  final apiKey;
  final testing;
  var userName;
  var userEmail;
  var currencyCode;
  var orderId;
  SitesWayPayment(
      {super.key,
      this.onSuccess,
      this.onFailed,
      required this.amount,
      required this.userEmail,
      required this.userName,
      required this.orderId,
      required this.currencyCode,
      this.brandId,
      this.apiKey,
      this.testing});
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
            future: waitForIt(testing, apiKey, brandId, amount),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: SizedBox(height: 40, child: CustomPreloader())),
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
                  onPageStarted: (String url) {},
                  onPageFinished: (String url) async {
                    if (url.contains('finish')) {
                      bool paySuccess = await verifyPayment(url);
                      if (paySuccess) {
                        onSuccess();
                        return;
                      }
                      onFailed();
                    }
                  },
                  onWebResourceError: (WebResourceError error) {},
                ));
              return WebViewWidget(controller: _controller);
            }),
      ),
    );
  }

  waitForIt(testing, apiKey, brandId, String amount) async {
    const baseUrl = "https://gate.sitesway.sa/api/v1/purchases/";
    final body = {
      "client": {"email": userEmail, "full_name": userName},
      "purchase": {
        "currency": currencyCode,
        "products": [
          {
            "name": "$appLabel payment",
            "price": amount * 100 // Price needs to be multiplied by 100
          }
        ]
      },
      "brand_id": brandId,
      "success_redirect": "$siteLink/success",
      "failure_redirect": "$siteLink/failed",
      "cancel_redirect": "$siteLink/failed",
      "success_callback": "",
      "reference": jsonEncode({'order_id': orderId, 'payment_type': "order"})
    };
    final responseData =
        await NetworkApiServices().postApi(body, baseUrl, null);
    url = 'https://gate.sitesway.sa';
  }

  Future<bool> verifyPayment(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    print(response.body.contains('successful'));
    return response.body.contains('successful');
  }
}
