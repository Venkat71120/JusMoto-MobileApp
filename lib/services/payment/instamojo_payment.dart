import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../customization.dart';
import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class InstamojoPayment extends StatelessWidget {
  final onSuccess;
  final onFailed;
  final testing;
  final int amount;
  final userName;
  final userPhone;
  final userEmail;
  final apiKey;
  final clientSecret;
  final clientId;
  InstamojoPayment({
    super.key,
    this.onSuccess,
    this.onFailed,
    this.testing,
    required this.amount,
    this.userName,
    this.userPhone,
    this.userEmail,
    this.apiKey,
    this.clientSecret,
    this.clientId,
  });
  String? selectedUrl;
  String? prevUrl;
  String? token;
  final WebViewController _controller = WebViewController();

  @override
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
              future: createRequest(
                context,
                testing,
                amount,
                userName,
                userEmail,
                userPhone,
                apiKey,
                clientSecret,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child:
                              SizedBox(height: 60, child: CustomPreloader())),
                    ],
                  );
                }
                try {
                  _controller
                    ..loadRequest(Uri.parse(selectedUrl ?? ''))
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setNavigationDelegate(NavigationDelegate(
                        onProgress: (int progress) {},
                        onPageStarted: (String url) {},
                        onPageFinished: (String url) {},
                        onWebResourceError: (WebResourceError error) {},
                        onNavigationRequest: (NavigationRequest request) async {
                          if (request.url.contains('xgenious')) {
                            if (prevUrl!.contains('status')) {
                              final response =
                                  await http.get(Uri.parse(prevUrl!));
                              if (response.body
                                  .contains('Payment Successful')) {
                                onSuccess();
                              }
                              if (!response.body
                                  .contains('Payment Successful')) {
                                onFailed();
                              }
                            }
                            return NavigationDecision.prevent;
                          }
                          prevUrl = request.url;
                          return NavigationDecision.navigate;
                        }));
                  print(selectedUrl);
                  return WebViewWidget(
                    controller: _controller,
                  );
                } catch (e) {
                  debugPrint(e.toString());
                  return Center(
                    child: LottieBuilder.asset(
                      "assets/animations/empty_list.json",
                      repeat: false,
                    ),
                  );
                }
              }),
        ));
  }

  Future createRequest(
    BuildContext context,
    testing,
    int amount,
    userName,
    userEmail,
    userPhone,
    apiKey,
    clientSecre,
  ) async {
    try {
      Map<String, String> body = {
        "amount": '$amount', //amount to be paid
        "purpose": "$appLabel Payment",
        "buyer_name": userName ?? "",
        "email": userEmail ?? "",
        "allow_repeated_payments": "true",
        "send_email": "true",
        "phone": userPhone ?? "",
        "send_sms": "false",
        "redirect_url": "https://www.xgenious.com/",

        "webhook": "https://www.xgenious.com/",
      };

      String authToken = "";
      var headers = {
        'Accept': 'application/json',
      };
      final prefix = testing ? "test" : "api";
      var request = http.MultipartRequest(
          'POST', Uri.parse("https://api.instamojo.com/oauth2/token"));
      request.fields.addAll({
        'grant_type': 'client_credentials',
        'client_id': '$clientId',
        'client_secret': '$clientSecre'
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final data = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        authToken = jsonDecode(data ?? "{}")["access_token"] ?? "";
      }
      Map<String, String> header = {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "X-Api-Key": apiKey ?? "",
        "X-Auth-Token": authToken
      };
      var resp = await http.post(
          Uri.parse(testing
              ? "https://$prefix.instamojo.com/api/1.1/payment-requests/"
              : "https://$prefix.instamojo.com/api/1.1/payment-requests/"),
          headers: header,
          body: body);
      debugPrint(resp.body);
      if (jsonDecode(resp.body)['success'] == true) {
//If request is successful take the longurl.

        selectedUrl =
            "${json.decode(resp.body)["payment_request"]?['longurl'] ?? "https://instamojo.com"}?embed=form";
        return;

//If something is wrong with the data we provided to
//create the Payment_Request. For Example, the email is in incorrect format, the payment_Request creation will fail.
      }
      try {
        jsonDecode(resp.body)['message']?.toString().showToast();
      } catch (e) {}
      selectedUrl = "https://instamojo.com";
    } catch (e) {
      selectedUrl = "https://instamojo.com";
      log(e.toString());
    }
  }
}
