import 'dart:convert';
import 'dart:developer';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/components/alerts.dart';
import '../../utils/components/navigation_pop_icon.dart';

class PayTRPayment extends StatelessWidget {
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

  PayTRPayment({
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
          future: createRequest(
            context,
            productName,
            amount,
            currency,
            maxInstallment,
            linkType,
            lang,
            merchantId,
            merchantKey,
            merchantSalt,
          ),
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
              return Center(child: EmptyWidget(title: ""));
            }
          },
        ),
      ),
    );
  }

  Future createRequest(
    BuildContext context,
    String name,
    int amount,
    String currency,
    String maxInstallment,
    String linkType,
    String lang,
    String merchantId,
    String merchantKey,
    String merchantSalt,
  ) async {
    try {
      // Build required string for token generation
      String required =
          name +
          (amount * 100).toStringAsFixed(0) +
          currency +
          maxInstallment +
          linkType +
          lang;

      // Generate PayTR token
      String paytrToken = _generateToken(required + merchantSalt, merchantKey);

      // Prepare required form data
      Map<String, String> formData = {
        'merchant_id': merchantId,
        'name': name,
        'price': (amount * 100).toStringAsFixed(0),
        'currency': currency,
        'max_installment': maxInstallment,
        'link_type': linkType,
        'lang': lang,
        'get_qr': '0',
        'paytr_token': paytrToken,
      };

      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};

      var resp = await http.post(
        Uri.parse('https://www.paytr.com/odeme/api/link/create'),
        headers: headers,
        body: formData,
      );
      log(jsonEncode(formData));
      debugPrint(resp.body);

      if (resp.statusCode == 200) {
        final responseData = json.decode(resp.body);

        if (responseData['status'] == 'success') {
          // Get the payment URL from the response
          selectedUrl =
              responseData['payment_url'] ??
              responseData['link'] ??
              responseData['url'] ??
              "https://paytr.com";
          return;
        } else {
          // Handle error response
          String errorMessage =
              responseData['reason'] ??
              responseData['message'] ??
              'Payment link creation failed';
          debugPrint('PayTR Error: $errorMessage');
          selectedUrl = "https://paytr.com";
        }
      } else {
        debugPrint('HTTP Error: ${resp.statusCode}');
        selectedUrl = "https://paytr.com";
      }
    } catch (e) {
      selectedUrl = "https://paytr.com";
      log(e.toString());
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
            (context) => PayTRPayment(
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
