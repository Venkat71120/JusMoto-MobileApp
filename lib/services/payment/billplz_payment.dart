import 'dart:async';
import 'dart:convert';

import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../customization.dart';
import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';

class BillplzPayment extends StatelessWidget {
  final onPaymentSuccess;
  final onPaymentFailed;
  final amount;
  final userMail;
  final userName;
  final paymentKey;
  final collectionId;
  final testing;
  final onSuccess;
  final onFailed;

  BillplzPayment({
    super.key,
    this.onPaymentSuccess,
    this.onPaymentFailed,
    this.amount,
    this.userMail,
    this.userName,
    this.paymentKey,
    this.onSuccess,
    this.onFailed,
    this.collectionId,
    this.testing = false,
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
            future: waitForIt(
                context, amount, userMail, userName, paymentKey, collectionId,
                testing: testing),
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

              _controller
                ..loadRequest(Uri.parse(url ?? ''))
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onProgress: (int progress) {},
                    onPageStarted: (String url) {},
                    onPageFinished: (String url) {
                      verifyPayment(url.toString(), context);
                    },
                    onWebResourceError: (WebResourceError error) {},
                    onNavigationRequest: (NavigationRequest request) {
                      if (request.url.contains("paid%5D=true") &&
                          request.url.contains("http://www.xgenious.com")) {
                        onPaymentSuccess();
                        return NavigationDecision.prevent;
                      }
                      if (request.url.contains("paid%5D=false") &&
                          request.url.contains("http://www.xgenious.com")) {
                        onPaymentFailed();
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    },
                  ),
                );
              return WebViewWidget(
                controller: _controller,
              );
            }),
      ),
    );
  }

  waitForIt(BuildContext context, amount, userMail, userName, paymentKey,
      collectionId,
      {testing = false}) async {
    final url = Uri.parse('https://www.billplz-sandbox.com/api/v3/bills');
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$paymentKey:$paymentKey'))}';
    final header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": basicAuth,
    };
    final response = await http.post(url,
        headers: header,
        body: jsonEncode({
          "collection_id": collectionId,
          "description": "$appLabel payment",
          "email": userMail,
          "name": userName,
          "amount": amount.toStringAsFixed(2),
          "reference_1_label": "Bank Code",
          "reference_1": "BP-FKR01",
          "redirect_url": siteLink,
          "callback_url": siteLink
        }));
    print(response.body);
    if (response.statusCode == 200) {
      this.url =
          jsonDecode(response.body)["url"] ?? "https://www.billplz-sandbox.com";
      return;
    }

    return true;
  }
}

Future verifyPayment(String url, BuildContext context,
    {onSuccess, onFailed}) async {
  final uri = Uri.parse(url);
  final response = await http.get(uri);
  if (response.body.contains('paid')) {
    onSuccess();
    return;
  }
  if (response.body.contains('your payment was not')) {
    onFailed();
    return;
  }
}
