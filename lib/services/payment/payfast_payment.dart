import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../customization.dart';
import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class PayfastPayment extends StatelessWidget {
  final onSuccess;
  final onFailed;
  final String amount;
  final merchantKey;
  final merchantId;
  final testing;
  PayfastPayment(
      {super.key,
      this.onSuccess,
      this.onFailed,
      required this.amount,
      this.merchantKey,
      this.merchantId,
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
            future: waitForIt(testing, merchantId, merchantKey, amount),
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

  waitForIt(testing, merchantId, merchantKey, String amount) {
    url =
        'https://${testing ? "sandbox." : ""}payfast.co.za/eng/process?merchant_id=$merchantId&merchant_key=$merchantKey&amount=$amount&item_name=$appLabel-Payment';

    debugPrint(url.toString());
  }

  Future<bool> verifyPayment(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    print(response.body.contains('successful'));
    return response.body.contains('successful');
  }
}
