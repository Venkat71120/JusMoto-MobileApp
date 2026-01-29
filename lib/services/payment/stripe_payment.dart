import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../customization.dart';

class StripePayment {
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment(BuildContext context, publicKey, secretKey,
      num amount, currencyCode, onSuccess, onFailed) async {
    if (publicKey == null || secretKey == null) {
      LocalKeys.invalidDeveloperKeys.showToast();
      return;
    }

    Stripe.publishableKey = publicKey.toString();
    await Stripe.instance.applySettings();
    try {
      paymentIntent = await createPaymentIntent(
          context, (amount * 100).round().toString(), currencyCode, secretKey);

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.light,
                  merchantDisplayName: appLabel))
          .then((value) {});

      displayPaymentSheet(context, onSuccess, onFailed);
    } catch (e, s) {
      onFailed();
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(BuildContext context, onSuccess, onFailed) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        onSuccess();

        paymentIntent = null;
      }).onError((error, stackTrace) async {
        print('Error is:--->$error $stackTrace');
        onFailed();
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      await onFailed();
    } catch (e) {
      print('$e');
      await onFailed();
    }
  }

  createPaymentIntent(
      BuildContext context, String amount, String currency, secretKey) async {
    Map<String, dynamic> body = {
      'amount': amount,
      'currency': currency,
      'payment_method_types[]': 'card'
    };

    var response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: body,
    );

    print('Payment Intent Body->>> ${response.body}');
    return jsonDecode(response.body);
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }
}
