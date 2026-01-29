import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../customization.dart';
import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class ToyyibPayPayment extends StatelessWidget {
  final String clientSecret;
  final String categoryCode;
  final String amount;
  final userName;
  final userPhone;
  final userEmail;
  final onSuccess;
  final onFailed;

  ToyyibPayPayment(
      {super.key,
      required this.clientSecret,
      required this.categoryCode,
      required this.amount,
      this.userName,
      this.userPhone,
      this.userEmail,
      this.onFailed,
      this.onSuccess});
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
            future: waitForIt(clientSecret, categoryCode, amount, userName,
                userPhone, userEmail),
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
                  onPageStarted: (String url) async {},
                  onPageFinished: (String url) async {},
                  onWebResourceError: (WebResourceError error) {},
                  onNavigationRequest: (request) {
                    if (request.url == "www.success.com") {
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

  waitForIt(String clientSecret, String categoryCode, String amount, userName,
      userPhone, userEmail) async {
//username&password:11234
    var headers = {'Content-Type': 'x-www-form-urlencoded'};
    var request = http.MultipartRequest('POST',
        Uri.parse('https://dev.toyyibpay.com/index.php/api/createBill'));
    debugPrint(clientSecret.toString());
    debugPrint(categoryCode.toString());
    debugPrint(amount.toString());
    request.fields.addAll({
      'userSecretKey': clientSecret ?? '',
      'categoryCode': categoryCode ?? '',
      'billName': "$appLabel payment",
      'billDescription': "$appLabel payment",
      'billPriceSetting': '1',
      'billAmount': amount,
      'billPayorInfo': '1',
      'billTo': userName,
      'billEmail': userEmail,
      'billPhone': userPhone,
      'cancel_url': 'www.cancel.com',
      'success_url': 'www.success.com'
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseData = jsonDecode(await response.stream.bytesToString());
      print(responseData);
      final billCode = responseData.first['BillCode'];
      url = 'https://dev.toyyibpay.com/$billCode';
    } else {
      print(response.reasonPhrase);
      return true;
    }
  }
}
