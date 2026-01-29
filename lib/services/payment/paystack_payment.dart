import 'dart:async';
import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class PaystackPayment extends StatelessWidget {
  final onSuccess;
  final onFailed;
  final secretKey;
  final num amount;
  final userEmail;
  final orderId;
  PaystackPayment({
    super.key,
    this.onSuccess,
    this.onFailed,
    this.secretKey,
    required this.amount,
    this.userEmail,
    this.orderId,
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
              secretKey,
              amount,
              userEmail,
              orderId,
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
              if (snapshot.hasData) {
                return Center(
                  child: Text(snapshot.data.toString()),
                );
              }
              if (snapshot.hasError) {
                print(snapshot.error);
              }
              _controller
                ..loadRequest(Uri.parse(url ?? ''))
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(NavigationDelegate(
                  onProgress: (int progress) {},
                  onPageStarted: (String url) {},
                  onPageFinished: (String url) async {},
                  onWebResourceError: (WebResourceError error) {},
                  onNavigationRequest: (request) {
                    if (request.url.contains('success')) {
                      onSuccess();
                      return NavigationDecision.prevent;
                    }
                    if (request.url.contains('failed')) {
                      onFailed();
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                ));
              return WebViewWidget(controller: _controller);
            }),
      ),
    );
  }

  Future waitForIt(
    secretKey,
    num amount,
    userEmail,
    orderId,
  ) async {
    final uri = Uri.parse('https://api.paystack.co/transaction/initialize');

    final header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $secretKey",
    };
    final response = await http.post(uri,
        headers: header,
        body: jsonEncode({
          "amount": amount * 100,
          "currency": "NGN",
          "email": userEmail,
          "reference_id": orderId.toString(),
          "callback_url": "http://success.com",
          "metadata": {"cancel_action": "http://failed.com"}
        }));
    print(response.body);
    if (response.statusCode == 200) {
      url = jsonDecode(response.body)['data']['authorization_url'];
      print(url);
      return;
    }
    LocalKeys.loadingFailed.showToast();
    return jsonDecode(response.body)['message'];
  }
}
