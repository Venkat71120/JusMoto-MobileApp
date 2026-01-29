import 'dart:core';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/components/alerts.dart';
import '../../utils/components/custom_future_widget.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/custom_refresh_indicator.dart';
import '../../utils/components/navigation_pop_icon.dart';
import 'paypal_service.dart';

class PaypalPayment extends StatefulWidget {
  final Function onSuccess;
  final Function onFailed;
  final String clientSecret;
  final String clientId;
  final amount;

  final currencyCode;
  final bool testMode;

  const PaypalPayment(
      {super.key,
      required this.onSuccess,
      required this.onFailed,
      this.amount,
      this.currencyCode,
      required this.clientSecret,
      this.testMode = false,
      required this.clientId});

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  var checkoutUrl;
  var executeUrl;
  var accessToken;
  PaypalServices services = PaypalServices();

  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "USD",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "USD"
  };

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';

  Map<String, dynamic> getOrderParams(
      BuildContext context, amount, currencyCode) {
    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": amount,
            "currency": "USD",
          },
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {
        "return_url": "return.example.com",
        "cancel_url": "cancel.example.com"
      }
    };

    return temp;
  }

  final WebViewController _controller = WebViewController();
  initiatePayment() async {
    accessToken = await services.getAccessToken(
      context,
      widget.clientId,
      widget.clientSecret,
      testMode: widget.testMode,
    );

    final transactions = getOrderParams(
      context,
      widget.amount,
      widget.currencyCode,
    );
    final res = await services.createPaypalPayment(
      transactions,
      accessToken,
      testMode: widget.testMode,
    );
    checkoutUrl = res["approvalUrl"] ?? res["executeUrl"];
    executeUrl = res["executeUrl"];
    if (checkoutUrl != null) {
      _controller
        ..loadRequest(Uri.parse(checkoutUrl ?? ''))
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (request) {
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);
              final payerID = uri.queryParameters['PayerID'];
              print(payerID);
              if (payerID != null) {
                services
                    .executePayment(executeUrl, payerID, accessToken)
                    .then((id) async {
                  widget.onSuccess();
                });
              } else {
                widget.onFailed();
              }
            }
            if (request.url.contains(cancelURL)) {
              widget.onFailed();
            }
            return NavigationDecision.navigate;
          },
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NavigationPopIcon(onTap: () async {
          Alerts().paymentFailWarning(context, onFailed: widget.onFailed);
        }),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await initiatePayment();
        },
        child: CustomFutureWidget(
          function: checkoutUrl == null ? initiatePayment() : null,
          shimmer: const CustomPreloader(),
          child: WillPopScope(
            onWillPop: () async {
              bool canGoBack = await _controller.canGoBack();
              if (canGoBack) {
                _controller.goBack();
                return false;
              }
              Alerts().paymentFailWarning(context, onFailed: widget.onFailed);
              return false;
            },
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
        ),
      ),
    );
  }
}
