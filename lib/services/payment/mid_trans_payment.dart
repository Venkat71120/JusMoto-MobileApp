import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class MidtransPayment extends StatelessWidget {
  final onSuccess;
  final testing;
  final serverKey;
  final clientKey;
  final id;
  final String amount;
  final userName;
  final userEmail;
  final userPhone;
  final onFailed;
  MidtransPayment({
    super.key,
    this.onSuccess,
    this.onFailed,
    this.testing,
    this.serverKey,
    this.clientKey,
    this.id,
    required this.amount,
    this.userName,
    this.userEmail,
    this.userPhone,
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
              testing,
              serverKey,
              clientKey,
              id,
              amount,
              userName,
              userEmail,
              userPhone,
            ),
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
                  onPageStarted: (String url) {},
                  onPageFinished: (String url) {
                    if (url.contains('success')) {
                      onSuccess();
                    }
                  },
                  onWebResourceError: (WebResourceError error) {},
                ));
              return WebViewWidget(controller: _controller);
            }),
      ),
    );
  }

  waitForIt(
    testing,
    serverKey,
    clientKey,
    id,
    String amount,
    userName,
    userEmail,
    userPhone,
  ) async {
    final url = Uri.parse(testing
        ? 'https://app.sandbox.midtrans.com/snap/v1/transactions'
        : 'https://app.midtrans.com/snap/v1/transactions');
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$serverKey:$clientKey'))}';
    final header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": basicAuth,
    };
    final response = await http.post(url,
        headers: header,
        body: jsonEncode({
          "transaction_details": {"order_id": id, "gross_amount": amount},
          "credit_card": {"secure": true},
          "customer_details": {
            "first_name": userName,
            "email": userEmail,
            "phone": userPhone,
          }
        }));
    print(response.body);
    if (response.statusCode == 201) {
      this.url = jsonDecode(response.body)['redirect_url'];
      return;
    }

    return true;
  }
}
