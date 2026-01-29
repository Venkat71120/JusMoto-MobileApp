// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../customization.dart';
import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class MolliePayment extends StatelessWidget {
  final onSuccess;
  final String amount;
  final String currency;
  final publicKey;
  var onFailed;
  MolliePayment(
      {super.key,
      this.onSuccess,
      this.onFailed,
      required this.amount,
      required this.currency,
      this.publicKey});
  String? url;
  String? statusURl;
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
            future: waitForIt(publicKey, amount, currency),
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
                  onNavigationRequest: (request) async {
                    if (request.url.contains('xgenious')) {
                      print('preventing navigation');
                      String status = await verifyPayment();
                      if (status == 'paid') {
                        onSuccess();
                      }
                      if (status == 'open') {}
                      if (status == 'failed') {}
                      if (status == 'expired') {}
                      return NavigationDecision.prevent;
                    }
                    if (request.url.contains('mollie')) {
                      return NavigationDecision.navigate;
                    }
                    return NavigationDecision.prevent;
                  },
                  onWebResourceError: (WebResourceError error) {},
                ));
              return WebViewWidget(
                controller: _controller,
              );
            }),
      ),
    );
  }

  waitForIt(publicKey, String amount, currency) async {
    final url = Uri.parse('https://api.mollie.com/v2/payments');
    final header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $publicKey",
    };
    final response = await http.post(url,
        headers: header,
        body: jsonEncode({
          "amount": {"value": amount, "currency": currency},
          "description": "$appLabel Payment",
          "redirectUrl": "http://www.xgenious.com",
          "webhookUrl": "http://www.xgenious.com",
          "metadata": "creditcard",
        }));
    debugPrint(response.body);
    if (response.statusCode == 201) {
      this.url = jsonDecode(response.body)['_links']['checkout']['href'];
      statusURl = jsonDecode(response.body)['_links']['self']['href'];
      debugPrint(statusURl.toString());
      return;
    }

    return true;
  }

  verifyPayment() async {
    final url = Uri.parse(statusURl as String);
    final header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $publicKey",
    };
    final response = await http.get(url, headers: header);
    debugPrint(response.body);
    return jsonDecode(response.body)['status'].toString();
  }
}
