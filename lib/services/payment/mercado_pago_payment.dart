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

class MercadopagoPayment extends StatelessWidget {
  final userMail;
  final int amount;
  final clientSecret;
  final testing;

  MercadopagoPayment({
    super.key,
    this.onSuccess,
    this.onFailed,
    this.userMail,
    required this.amount,
    this.clientSecret,
    this.testing,
  });
  String? url;
  final onSuccess;
  final onFailed;
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
            future:
                getPaymentUrl(context, testing, clientSecret, amount, userMail),
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
                    onPageFinished: (String url) {},
                    onWebResourceError: (WebResourceError error) {},
                    onNavigationRequest: (NavigationRequest request) async {
                      if (request.url.contains('success')) {
                        onSuccess();
                        return NavigationDecision.prevent;
                      }
                      if (request.url.contains('failure') ||
                          request.url.contains('pending')) {
                        onFailed();
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    }));
              return WebViewWidget(
                controller: _controller,
              );
            }),
      ),
    );
  }

  Future<dynamic> getPaymentUrl(
      BuildContext context, testing, clientSecret, int amount, userMail) async {
    if (clientSecret == null) {
      LocalKeys.invalidDeveloperKeys.showToast();
      return;
    }
    var header = {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };

    var data = jsonEncode({
      "items": [
        {
          "title": "$appLabel Payment",
          "description": "$appLabel Payment",
          "quantity": 1,
          "currency_id": 'ARS',
          "unit_price": amount
        }
      ],
      "payer": {"email": userMail},
      "back_urls": {
        "failure": "failure.com",
        "pending": "pending.com",
        "success": "success.com"
      },
      "auto_return": "approved"
    });

    var response = await http.post(
        Uri.parse(
            'https://api.mercadopago.com/checkout/preferences?access_token=$clientSecret'),
        headers: header,
        body: data);

    print(response.body);
    if (response.statusCode == 201) {
      url = jsonDecode(response.body)['init_point'];
      print(response.body);

      return;
    }
    return '';
  }
}
