import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/view_models/quote_view_model/quote_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/quote_services/quote_service.dart';

class QuoteDetailsView extends StatefulWidget {
  final int quoteId;
  const QuoteDetailsView({super.key, required this.quoteId});

  @override
  State<QuoteDetailsView> createState() => _QuoteDetailsViewState();
}

class _QuoteDetailsViewState extends State<QuoteDetailsView> {
  final qvm = QuoteViewModel.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      qvm.fetchQuoteDetails(context, widget.quoteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quote Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<QuoteService>(
        builder: (context, qs, child) {
          final quote = qs.quoteDetail;
          return CustomFutureWidget(
            isLoading: qs.isLoadingDetail,
            child:
                quote == null
                    ? const Center(child: Text("Quote not found"))
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusHeader(quote: quote),
                          24.toHeight,
                          const Text(
                            "Service Details",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          16.toHeight,
                          _DetailItem(label: "Title", value: quote.title),
                          _DetailItem(
                            label: "Type",
                            value: quote.type.toUpperCase(),
                          ),
                          _DetailItem(
                            label: "Requested On",
                            value: quote.createdAt.split('T')[0],
                          ),
                          16.toHeight,
                          const Text(
                            "Description",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          8.toHeight,
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(quote.description),
                          ),
                          24.toHeight,
                          if (quote.quotedPrice != null ||
                              quote.adminNote != null) ...[
                            const Divider(),
                            24.toHeight,
                            const Text(
                              "Provider Response",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            16.toHeight,
                            if (quote.quotedPrice != null)
                              _DetailItem(
                                label: "Quoted Price",
                                value: "₹${quote.quotedPrice}",
                                valueColor: primaryColor,
                                valueSize: 20,
                                isBold: true,
                              ),
                            if (quote.adminNote != null) ...[
                              8.toHeight,
                              const Text(
                                "Notes from Provider",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              8.toHeight,
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(quote.adminNote!),
                              ),
                            ],
                          ] else ...[
                            24.toHeight,
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 48,
                                    color: Colors.orange[200],
                                  ),
                                  12.toHeight,
                                  const Text(
                                    "Our team is reviewing your request.\nYou will be notified once the quote is ready.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final dynamic quote;
  const _StatusHeader({required this.quote});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.orange;
    if (quote.status.toLowerCase() == 'reviewed') statusColor = Colors.green;
    if (quote.status.toLowerCase() == 'rejected') statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: statusColor, radius: 4),
          12.toWidth,
          Text(
            "Status: ${quote.status.toUpperCase()}",
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final double? valueSize;
  final bool isBold;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueSize,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black,
              fontSize: valueSize ?? 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
