import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iyzi_dart/enums/item_types.dart';
import 'package:iyzi_dart/enums/status.dart' show Status;
import 'package:iyzi_dart/iyzi_dart.dart';
import 'package:iyzi_dart/models/iyzi_address.dart';
import 'package:iyzi_dart/models/iyzi_basket_item.dart';
import 'package:iyzi_dart/models/iyzi_buyer.dart';
import 'package:iyzi_dart/models/iyzi_card.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';

class IyzicoPaymentScreen extends StatelessWidget {
  final String cardHolderName;
  final String cardNumber;
  final String expireMonth;
  final String expireYear;
  final String cvc;
  final onSuccess;
  final onFailed;
  final String amount;
  final merchantKey;
  final merchantId;
  final testing;
  final Function? onTransactionFailed;
  final Function? onTransactionApproved;
  final dynamic orderId;

  IyzicoPaymentScreen({
    super.key,
    required this.orderId,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expireMonth,
    required this.expireYear,
    required this.cvc,
    this.onSuccess,
    this.onFailed,
    required this.amount,
    this.merchantKey,
    this.merchantId,
    this.testing,
    this.onTransactionFailed,
    this.onTransactionApproved,
  });

  String? url;
  final WebViewController _controller = WebViewController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NavigationPopIcon(
          onTap: () async {
            Alerts().paymentFailWarning(context, onFailed: onFailed);
          },
        ),
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
          future: initiatePayment(
            context,
            testing,
            merchantId,
            merchantKey,
            amount,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: SizedBox(height: 60, child: CustomPreloader())),
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
              ..setNavigationDelegate(
                NavigationDelegate(
                  onProgress: (int progress) {},
                  onPageStarted: (String url) {},
                  onPageFinished: (String url) async {
                    if (url.contains('finish')) {
                      // bool paySuccess = await verifyPayment(url);
                      // if (paySuccess) {
                      //   onSuccess();
                      //   return;
                      // }
                      onFailed();
                    }
                  },
                  onWebResourceError: (WebResourceError error) {},
                ),
              );
            return WebViewWidget(controller: _controller);
          },
        ),
      ),
    );
  }

  Future<void> initiatePayment(
    BuildContext context,
    testing,
    merchantId,
    merchantKey,
    amount,
  ) async {
    final url = Uri.parse(
      'https://${testing ? "sandbox-api" : "api"}.iyzipay.com/payment/auth',
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Your Basic Auth Header or Iyzico Hash Here',
    };

    final body = {
      "locale": "en",
      "conversationId": orderId,
      "price": amount.tryToParse.toStringAsFixed(2),
      "paidPrice": amount.tryToParse.toStringAsFixed(2),
      "installment": 1,
      "paymentChannel": "MOBILE",
      "paymentGroup": "PRODUCT",
      "currency": "TRY",
      "paymentCard": {
        "cardHolderName": cardHolderName,
        "cardNumber": cardNumber,
        "expireMonth": expireMonth,
        "expireYear": expireYear,
        "cvc": cvc,
        "registerCard": 0,
      },
      "buyer": {
        "id": "BY789",
        "name": "John",
        "surname": "Doe",
        "identityNumber": "74300864791",
        "email": "john.doe@email.com",
        "gsmNumber": "+905350000000",
        "registrationAddress": "Sample Street 123",
        "city": "Istanbul",
        "country": "Turkey",
        "ip": "85.34.78.112",
      },
      "billingAddress": {
        "contactName": "John Doe",
        "city": "Istanbul",
        "country": "Turkey",
        "address": "Sample Street 123",
      },
      "shippingAddress": {
        "contactName": "John Doe",
        "city": "Istanbul",
        "country": "Turkey",
        "address": "Sample Street 123",
      },
      "basketItems": [
        {
          "id": "BI101",
          "name": "Car Service",
          "category1": "Services",
          "itemType": "VIRTUAL",
          "price": amount.tryToParse.toStringAsFixed(2),
        },
      ],
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      debugPrint("Payment Success: ${responseData['status']}");
      if (onTransactionApproved != null) {
        onTransactionApproved!();
        return;
      }
    } else {
      debugPrint("Payment Failed: ${response.body}");

      onTransactionFailed!();
    }
  }

  Future<String?> _initializePayment() async {
    final String apiKey = 'sandbox-api-key';
    final String secretKey = 'sandbox-secret-key';
    final String baseUrl = 'https://sandbox-api.iyzipay.com';
    final String callbackUrl = 'https://your-callback-url.com';
    final config = IyziConfig(
      baseUrl: baseUrl,
      callBackUrl: callbackUrl,
      apiKey: apiKey,
      secretKey: secretKey,
      randomKey: 'random-key',
    );

    final iyziDart = IyziDart(config);

    final card = IyziCard(
      cardHolderName: 'John Doe',
      cvc: '123',
      expireMonth: '12',
      expireYear: '2030',
      cardNumber: '5400010000000004',
    );

    final basketItem = IyziBasketItem(
      id: 'item1',
      price: '100.00',
      name: 'Test Product',
      category1: 'Category',
      itemType: ItemTypes.VIRTUAL,
    );

    final billingAddress = IyziAddress(
      address: '123 Main Street',
      contactName: 'John Doe',
      city: 'Istanbul',
      country: 'Turkey',
      zipCode: '34000',
    );

    final buyer = IyziBuyer(
      id: 'user123',
      name: 'John',
      surname: 'Doe',
      identityNumber: '',
      email: 'john.doe@example.com',
      registrationAddress: '123 Main Street',
      city: 'Istanbul',
      country: 'Turkey',
      ip: '',
      gsmNumber: '+905350000000',
      registrationDate: '2023-01-01 12:00:00',
      lastLoginDate: '2023-01-01 12:00:00',
    );

    final response = await iyziDart.initializePayment(
      conversationId: 'conv123',
      card: card,
      buyer: buyer,
      billingAddress: billingAddress,
      shippingAddress: billingAddress,
      basketItems: [basketItem],
    );

    if (response.status == Status.success) {
      final responseData = response.convertHtml();
      log(responseData.toString());
      return responseData;
    } else {
      debugPrint('Payment initialization failed: ${response.errorMessage}');
      return null;
    }
  }
}
