// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/components/alerts.dart';
import '../../utils/components/navigation_pop_icon.dart';

class ZitopayPayment extends StatelessWidget {
  ZitopayPayment(this.userName,
      {super.key,
      this.currencyCode,
      required this.amount,
      required this.username,
      required this.onSuccess,
      this.onFailed});
  String? userName;
  final currencyCode;
  final double amount;
  final String username;
  final onSuccess;
  final onFailed;
  final WebViewController _controller = WebViewController();
  @override
  Widget build(BuildContext context) {
    final url =
        'https://zitopay.africa/sci/?currency=$currencyCode&amount=${amount.toStringAsFixed(2)}&receiver=$username';

    _controller
      ..loadRequest(Uri.parse(url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {},
        onPageStarted: (String url) async {},
        onPageFinished: (String url) async {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (request) async {
          if (!request.url.contains('confirm_trans')) {
            return NavigationDecision.navigate;
          }
          bool paySuccess = await verifyPayment(request.url);
          if (paySuccess) {
            onSuccess();
          } else {
            onFailed();
          }
          return NavigationDecision.prevent;
        },
      ));
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
          child: WebViewWidget(controller: _controller),
        ));
  }
}

Future<bool> verifyPayment(String url) async {
  final uri = Uri.parse(url);
  final response = await http.get(uri);
  return response.body.contains('successful');
}
