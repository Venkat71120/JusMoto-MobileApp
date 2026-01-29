import 'dart:convert';

import 'package:car_service/customization.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class FlutterWavePayment {
  late BuildContext context;
  String currency = dProvider.currencyCode;

  void makePayment(BuildContext context, publicKey, secretKey, double amount,
      userName, userPhone, userMail, onSuccess, onFailed) async {
    this.context = context;
    _handlePaymentInitialization(context, publicKey, secretKey, amount,
        userName, userPhone, userMail, onSuccess, onFailed);
  }

  _handlePaymentInitialization(BuildContext context, publicKey, secretKey,
      double amount, userName, userPhone, userMail, onSuccess, onFailed) async {
    debugPrint(publicKey.toString());
    debugPrint(secretKey.toString());
    if (publicKey == null || secretKey == null) {
      LocalKeys.invalidDeveloperKeys.showToast();
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => FlutterwavePayment(
          amount: amount,
          publicKey: publicKey,
          secretKey: secretKey,
          username: userName,
          onSuccess: onSuccess,
          onFailed: onFailed,
          userEmailAddress: userMail,
        ),
      ),
    );
  }
}

class FlutterwavePayment extends StatelessWidget {
  final onSuccess;
  final onFailed;
  final amount;
  final publicKey;
  final secretKey;
  final testing;
  final username;
  final userEmailAddress;
  FlutterwavePayment(
      {super.key,
      this.onSuccess,
      this.onFailed,
      required this.amount,
      this.publicKey,
      this.secretKey,
      this.username,
      this.userEmailAddress,
      this.testing});
  String? url;
  String? transactionId;
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
            future: waitForIt(testing, secretKey, publicKey, amount),
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
                    if (url.contains('Thanks for your payment!')) {}
                  },
                  onNavigationRequest: (NavigationRequest request) async {
                    if (!request.url.contains("$siteLink/flutterwave/verify")) {
                      return NavigationDecision.navigate;
                    }
                    if (request.url.contains("status=cancelled")) {
                      onFailed();
                      return NavigationDecision.prevent;
                    }
                    transactionId = request.url.split("=").last ?? '';
                    showGeneralDialog(
                        context: context,
                        pageBuilder: (context, a, b) {
                          return Material(
                              color: context.color.primaryContrastColor
                                  .withOpacity(.05),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 44,
                                      width: 44,
                                      child: FittedBox(
                                          child: const CustomPreloader()),
                                    ),
                                  ],
                                ),
                              ));
                        });
                    bool paySuccess = await verifyPayment();
                    context.pop;
                    if (paySuccess) {
                      onSuccess();
                    } else {
                      onFailed();
                    }
                    debugPrint(request.url.toString());
                    return NavigationDecision.prevent;
                  },
                  onWebResourceError: (WebResourceError error) {},
                ));
              return WebViewWidget(controller: _controller);
            }),
      ),
    );
  }

  waitForIt(testing, secretKey, publicKey, amount) async {
    debugPrint(amount.toString());
    var headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $secretKey'
    };
    var request = http.Request(
        'POST', Uri.parse('https://api.flutterwave.com/v3/payments'));
    request.body = jsonEncode({
      "public_key": "$publicKey",
      "tx_ref": "$appLabel-${DateTime.now().millisecondsSinceEpoch}",
      "amount": amount,
      "currency": dProvider.currencyCode,
      "payment_options": "card, ussd",
      "redirect_url": "$siteLink/flutterwave/verify",
      "meta": {"token": 54},
      "customer": {
        "name": username,
        "email": userEmailAddress ?? "example@gmail.com"
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final tempData = await response.stream.bytesToString();
      final data = jsonDecode(tempData);
      url = data['data']['link'];
      transactionId = url?.split("/").last ?? '';
    } else {
      print(response.reasonPhrase);
    }
    debugPrint(url.toString());
  }

  Future<bool> verifyPayment() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $secretKey'
    };
    debugPrint(
        "https://api.flutterwave.com/v3/transactions/$transactionId/verify"
            .toString());
    final uri = Uri.parse(
        "https://api.flutterwave.com/v3/transactions/$transactionId/verify");
    final response = await http.get(uri, headers: headers);
    debugPrint(response.body.toString());
    final data = jsonDecode(response.body);
    return data['status'] == 'success';
  }
}
