import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/components/alerts.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/navigation_pop_icon.dart';
import 'iyzipay_model.dart';

class IyzipayPayment extends StatelessWidget {
  final onSuccess;
  final onFailed;
  final String amount;
  final secretKey;
  final apiKey;
  final testing;
  IyzipayPayment(
      {super.key,
      this.onSuccess,
      this.onFailed,
      required this.amount,
      this.secretKey,
      this.apiKey,
      this.testing});
  String? url;
  final WebViewController _controller = WebViewController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NavigationPopIcon(onTap: () async {
          Alerts().paymentFailWarning(context);
        }),
      ),
      body: WillPopScope(
        onWillPop: () async {
          bool canGoBack = await _controller.canGoBack();
          if (canGoBack) {
            _controller.goBack();
            return false;
          }
          Alerts().paymentFailWarning(context);
          return false;
        },
        child: FutureBuilder(
            future: waitForIt(testing, apiKey, secretKey, amount),
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

  waitForIt(testing, apiKey, secretKey, String amount) async {
    final paymentRequest = PaymentRequest(
      locale: 'tr',
      conversationId: '123456789',
      price: 1.0,
      basketId: 'B67832',
      paymentGroup: 'PRODUCT',
      buyer: Buyer(
        id: 'BY789',
        name: 'John',
        surname: 'Doe',
        identityNumber: '74300864791',
        email: 'email@email.com',
        gsmNumber: '+905350000000',
        registrationDate: '2013-04-21 15:12:09',
        lastLoginDate: '2015-10-05 12:43:35',
        registrationAddress:
            'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
        city: 'Istanbul',
        country: 'Turkey',
        zipCode: '34732',
        ip: '85.34.78.112',
      ),
      shippingAddress: Address(
        address: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
        zipCode: '34742',
        contactName: 'Jane Doe',
        city: 'Istanbul',
        country: 'Turkey',
      ),
      billingAddress: Address(
        address: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
        zipCode: '34742',
        contactName: 'Jane Doe',
        city: 'Istanbul',
        country: 'Turkey',
      ),
      basketItems: [
        BasketItem(
          id: 'BI101',
          price: 0.3,
          name: 'Binocular',
          category1: 'Collectibles',
          category2: 'Accessories',
          itemType: 'PHYSICAL',
        ),
        BasketItem(
          id: 'BI102',
          price: 0.5,
          name: 'Game code',
          category1: 'Game',
          category2: 'Online Game Items',
          itemType: 'VIRTUAL',
        ),
        BasketItem(
          id: 'BI103',
          price: 0.2,
          name: 'Usb',
          category1: 'Electronics',
          category2: 'Usb / Cable',
          itemType: 'PHYSICAL',
        ),
      ],
      enabledInstallments: [1, 2, 3, 6, 9],
      callbackUrl: 'https://www.merchant.com/callback',
      currency: 'TRY',
      paidPrice: 1.2,
    );
    final paymentString = paymentRequest
        .toJson()
        .toString()
        .replaceAll('{', "[")
        .replaceAll('}', "]")
        .replaceAll(" ", "")
        .replaceAll(":", "=");
    String pkString = "$apiKey&55665541$secretKey$paymentString";
    pkString =
        "sandbox-wtyih1LNnlN1FtCei29rVjbZRKfqVeUC123456789sandbox-QsgXTUpizlCZzHaypMJwkL8YTMGsYMBM[locale=tr,conversationId=123456789,price=1.0,basketId=B67832,paymentGroup=PRODUCT,buyer=[id=BY789,name=John,surname=Doe,identityNumber=74300864791,email=email@email.com,gsmNumber=+905350000000,registrationDate=2013-04-21 15:12:09,lastLoginDate=2015-10-05 12:43:35,registrationAddress=Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1,city=Istanbul,country=Turkey,zipCode=34732,ip=85.34.78.112],shippingAddress=[address=Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1,zipCode=34742,contactName=Jane Doe,city=Istanbul,country=Turkey],billingAddress=[address=Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1,zipCode=34742,contactName=Jane Doe,city=Istanbul,country=Turkey],basketItems=[[id=BI101,price=0.3,name=Binocular,category1=Collectibles,category2=Accessories,itemType=PHYSICAL], [id=BI102,price=0.5,name=Game code,category1=Game,category2=Online Game Items,itemType=VIRTUAL], [id=BI103,price=0.2,name=Usb,category1=Electronics,category2=Usb / Cable,itemType=PHYSICAL]],callbackUrl=https://www.merchant.com/callback,currency=TRY,paidPrice=1.2,enabledInstallments=[1, 2, 3, 6, 9]]";
    final base64String = base64(secretKey, pkString);
    debugPrint("base64String".toString());
    debugPrint(base64String.toString());
    var headers = {
      'Authorization': 'IYZWS $apiKey:$base64String',
      'x-iyzi-rnd': '55665541',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://${testing ? "sandbox-" : ""}api.iyzipay.com/payment/iyzipos/checkoutform/initialize/auth/ecom'));
    request.body = jsonEncode(paymentRequest.toJson());
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    print(await response.stream.bytesToString());

    url = 'https://iyzipay.com';
  }

  Future<bool> verifyPayment(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    print(response.body.contains('successful'));
    return response.body.contains('successful');
  }

  String base64(String key, String data) {
    final keyBytes = const Utf8Encoder().convert(key);
    log(data);
    final sha1Value = sha1.convert(utf8.encode(data)).toString();
    debugPrint("sha1 value is $sha1Value".toString());
    final dataBytes = const Utf8Encoder().convert(sha1Value);

    final hmacBase64 = base64Encode(dataBytes);
    return hmacBase64;
  }
}
