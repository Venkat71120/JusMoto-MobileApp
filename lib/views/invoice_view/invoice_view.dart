import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

import '../../customizations/colors.dart';
import '../../helper/app_urls.dart';
import '../../helper/local_keys.g.dart';

/// Call from any button to view/download invoice.
Future<void> downloadInvoicePdf(
  BuildContext context, {
  required dynamic orderId,
  String? invoiceNumber,
}) async {
  if (!context.mounted) return;
  context.toPage(_InvoicePage(
    orderId: orderId,
    invoiceNumber: invoiceNumber,
  ));
}

class _InvoicePage extends StatefulWidget {
  final dynamic orderId;
  final String? invoiceNumber;

  const _InvoicePage({required this.orderId, this.invoiceNumber});

  @override
  State<_InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<_InvoicePage> {
  InAppWebViewController? _webController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _html;

  @override
  void initState() {
    super.initState();
    _fetchHtml();
  }

  Future<void> _fetchHtml() async {
    try {
      final url = '${AppUrls.orderInvoiceUrl}/${widget.orderId}/invoice';
      if (kDebugMode) debugPrint('Fetching invoice: $url');

      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $getToken',
        'Accept': 'text/html',
      }).timeout(const Duration(seconds: 20));

      if (res.statusCode != 200 || res.body.isEmpty) {
        _setError();
        return;
      }

      // Remove all <img> tags to avoid broken logo / alignment issues.
      String html = res.body.replaceAll(RegExp(r'<img[^>]*/?>', caseSensitive: false), '');

      // Inject print-friendly CSS so the PDF comes out at correct A4 size.
      const printCss = '''
<style>
  @media print {
    @page { size: A4; margin: 10mm; }
    body { width: 100% !important; margin: 0 !important; padding: 0 !important; }
    table { width: 100% !important; page-break-inside: avoid; }
  }
  body { width: 100%; margin: 0; padding: 8px; box-sizing: border-box; }
  table { width: 100%; border-collapse: collapse; }
  * { box-sizing: border-box; max-width: 100%; }
</style>
''';
      // Inject before </head> or prepend.
      if (RegExp(r'</head>', caseSensitive: false).hasMatch(html)) {
        html = html.replaceFirstMapped(
          RegExp(r'</head>', caseSensitive: false),
          (m) => '$printCss${m[0]}',
        );
      } else {
        html = '$printCss$html';
      }

      if (mounted) setState(() => _html = html);
    } catch (e) {
      if (kDebugMode) debugPrint('Invoice error: $e');
      _setError();
    }
  }

  void _setError() {
    if (mounted) setState(() { _hasError = true; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.invoiceNumber != null
              ? 'Invoice #${widget.invoiceNumber}'
              : LocalKeys.downloadInvoice,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _webController != null && !_isLoading
                ? () async {
                    try {
                      await _webController!.printCurrentPage();
                    } catch (e) {
                      if (kDebugMode) debugPrint('Print error: $e');
                      'Could not open print dialog'.showToast();
                    }
                  }
                : null,
            icon: Icon(
              Icons.download_rounded,
              color: !_isLoading && !_hasError ? primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
      body: _hasError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text('Failed to load invoice'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _isLoading = true;
                        _html = null;
                      });
                      _fetchHtml();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor),
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                if (_html != null)
                  InAppWebView(
                    initialData: InAppWebViewInitialData(data: _html!),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      useWideViewPort: true,
                      loadWithOverviewMode: true,
                    ),
                    onWebViewCreated: (c) => _webController = c,
                    onLoadStop: (c, u) {
                      if (mounted) setState(() => _isLoading = false);
                    },
                  ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
              ],
            ),
    );
  }
}
