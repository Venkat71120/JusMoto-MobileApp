import 'dart:convert';
import 'dart:developer';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/components/alerts.dart';
import '../../utils/components/empty_widget.dart';
import '../../utils/components/navigation_pop_icon.dart';

class PaytrApiPayment extends StatelessWidget {
  final onSuccess;
  final onFailed;
  final String productName;
  final int amount; // Amount in kuruş (e.g., 1000 for 10.00 TL)
  final String currency;
  final String maxInstallment;
  final String linkType;
  final String lang;
  final String? userName;
  final String? userPhone;
  final String? userEmail;

  // PayTR Credentials
  final String merchantId;
  final String merchantKey;
  final String merchantSalt;

  PaytrApiPayment({
    super.key,
    this.onSuccess,
    this.onFailed,
    required this.productName,
    required this.amount,
    this.currency = 'TL',
    this.maxInstallment = '12',
    this.linkType = 'product',
    this.lang = 'tr',
    this.userName,
    this.userPhone,
    this.userEmail,
    required this.merchantId,
    required this.merchantKey,
    required this.merchantSalt,
  });

  String? selectedUrl;
  String? errorMessage;
  String? prevUrl;
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
          context.pop();
          return false;
          bool canGoBack = await _controller.canGoBack();
          if (canGoBack) {
            _controller.goBack();
            return false;
          }
          Alerts().paymentFailWarning(context, onFailed: onFailed);
          return false;
        },
        child: FutureBuilder(
          future: createPaymentRequest(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }
            try {
              _controller
                ..loadRequest(Uri.parse(selectedUrl ?? ''))
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onProgress: (int progress) {},
                    onPageStarted: (String url) {},
                    onPageFinished: (String url) {},
                    onWebResourceError: (WebResourceError error) {},
                    onNavigationRequest: (NavigationRequest request) async {
                      // Check for PayTR success/failure patterns
                      // if (request.url.contains('success') ||
                      //     request.url.contains('completed') ||
                      //     request.url.contains('payment_successful')) {
                      //   onSuccess();
                      //   return NavigationDecision.prevent;
                      // }

                      // if (request.url.contains('failed') ||
                      //     request.url.contains('cancel') ||
                      //     request.url.contains('error')) {
                      //   onFailed();
                      //   return NavigationDecision.prevent;
                      // }

                      prevUrl = request.url;
                      return NavigationDecision.navigate;
                    },
                  ),
                );
              print(selectedUrl);
              return WebViewWidget(controller: _controller);
            } catch (e) {
              debugPrint(e.toString());
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: context.height,
                  minWidth: context.width,
                ),
                child: Center(child: EmptyWidget(title: errorMessage ?? "")),
              );
            }
          },
        ),
      ),
    );
  }

  Future createPaymentRequest() async {
    try {
      // Generate merchant order ID (similar to Node.js version)
      String merchantOid = 'IN${DateTime.now().millisecondsSinceEpoch}';

      // Calculate total amount in kuruş
      String totalAmount = (amount * 100).toStringAsFixed(0);

      // Create basket (similar to Node.js version)
      List<List<dynamic>> basket = [
        [productName, (amount).toStringAsFixed(2), 1],
      ];
      String userBasket = jsonEncode(basket);

      // Build required string for token generation
      String hashString =
          '$merchantId$merchantOid${userEmail ?? 'test@paytr.com'}${totalAmount}card0${currency}10'; // non_3d

      log('Hash String: $hashString');
      dynamic userIp = await getExternalIp();
      // Generate PayTR token
      String paytrToken = hashString + merchantSalt;
      String token = _generateToken(paytrToken, merchantKey);

      log('Generated Token: $token');

      // Prepare form data for PayTR API
      Map<String, String> formData = {
        'merchant_id': merchantId,
        'user_ip': '$userIp', // Empty for mobile
        'merchant_oid': merchantOid,
        'email': userEmail ?? 'test@paytr.com',
        'payment_type': 'card',
        'payment_amount': totalAmount,
        'currency': currency,
        'test_mode': '1', // Set to '0' for production
        'non_3d': '0',
        'merchant_ok_url': 'https://www.paytr.com/demo/merchant_ok.php',
        'merchant_fail_url': 'https://www.paytr.com/demo/merchant_fail.php',
        'user_name': userName ?? 'Test User',
        'user_address': 'Test Address',
        'user_phone': userPhone ?? '05555555555',
        'user_basket': userBasket,
        'debug_on': '1',
        'client_lang': lang,
        'paytr_token': token,
        'non3d_test_failed': '0',
        'installment_count': '0',
        'card_type': '',
      };

      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};

      log('Sending request to PayTR API...');
      log('Form data: ${jsonEncode(formData)}');

      var response = await http.post(
        Uri.parse('https://www.paytr.com/odeme/api/get-token'),
        headers: headers,
        body: formData,
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          // Get the payment URL from the response
          selectedUrl = responseData['token'];
          if (selectedUrl != null && selectedUrl!.isNotEmpty) {
            selectedUrl = 'https://www.paytr.com/odeme/guvenlik/$selectedUrl';
            log('Payment URL: $selectedUrl');
          } else {
            throw Exception('Payment token not received');
          }
        } else {
          // Handle error response
          String errorReason = responseData['reason'] ?? 'Unknown error';
          throw Exception('PayTR Error: $errorReason');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Error creating payment request: $e');
      errorMessage = e.toString();
    }
  }

  /// Generate HMAC SHA256 token
  String _generateToken(String data, String key) {
    log(data);
    log(key);
    var keyBytes = utf8.encode(key);
    var dataBytes = utf8.encode(data);
    var hmacSha256 = Hmac(sha256, keyBytes);
    var digest = hmacSha256.convert(dataBytes);
    return base64.encode(digest.bytes);
  }

  Future<String?> getExternalIp() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipify.org?format=text'),
      );
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print('Failed to get external IP: $e');
    }
    return null;
  }
}

// Example usage
class PayTRExample extends StatefulWidget {
  const PayTRExample({super.key});

  @override
  _PayTRExampleState createState() => _PayTRExampleState();
}

class _PayTRExampleState extends State<PayTRExample> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Test Ürün',
  );
  final TextEditingController _priceController = TextEditingController(
    text: '1000',
  );
  String _selectedCurrency = 'TL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PayTR Payment Example'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price (in kuruş)',
                border: OutlineInputBorder(),
                helperText: 'e.g., 1000 for 10.00 TL',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items:
                  ['TL', 'EUR', 'USD', 'GBP', 'RUB'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCurrency = newValue!;
                });
              },
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _startPayment,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Start Payment',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaytrApiPayment(
              productName: _nameController.text,
              amount: int.parse(_priceController.text),
              currency: _selectedCurrency,
              maxInstallment: '12',
              linkType: 'product',
              lang: 'tr',
              merchantId: 'YOUR_MERCHANT_ID',
              merchantKey: 'YOUR_MERCHANT_KEY',
              merchantSalt: 'YOUR_MERCHANT_SALT',
              onSuccess: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment successful!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              onFailed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment failed!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayTR Flutter Integration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PayTRExample(),
    );
  }
}
