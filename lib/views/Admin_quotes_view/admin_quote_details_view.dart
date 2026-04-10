import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:car_service/view_models/admin_view_models/admin_quote_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/quote_services/quote_service.dart';

class AdminQuoteDetailsView extends StatefulWidget {
  final int quoteId;
  const AdminQuoteDetailsView({super.key, required this.quoteId});

  @override
  State<AdminQuoteDetailsView> createState() => _AdminQuoteDetailsViewState();
}

class _AdminQuoteDetailsViewState extends State<AdminQuoteDetailsView> {
  final aqvm = AdminQuoteViewModel.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      aqvm.fetchQuoteDetails(context, widget.quoteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quote Request Details"),
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
                      child: Form(
                        key: aqvm.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("User Request"),
                            16.toHeight,
                            _InfoRow(label: "Title", value: quote.title),
                            _InfoRow(
                              label: "Type",
                              value: quote.type.toUpperCase(),
                            ),
                            _InfoRow(
                              label: "Status",
                              value: quote.status.toUpperCase(),
                            ),
                            _InfoRow(
                              label: "Date",
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(quote.description),
                            ),
                            32.toHeight,
                            _buildSectionTitle("Your Response"),
                            16.toHeight,
                            FieldWithLabel(
                              label: "Quoted Price (₹)",
                              hintText: "Enter final price",
                              controller: aqvm.priceController,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return "Price is required to review";
                                if (double.tryParse(v) == null)
                                  return "Invalid price";
                                return null;
                              },
                            ),
                            16.toHeight,
                            FieldWithLabel(
                              label: "Admin Notes",
                              hintText: "Add any notes for the user...",
                              controller: aqvm.noteController,
                              minLines: 3,
                            ),
                            40.toHeight,
                            ValueListenableBuilder<bool>(
                              valueListenable: aqvm.isLoading,
                              builder: (context, loading, child) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        btText: "Reject",
                                        onPressed:
                                            () => aqvm.submitQuoteResponse(
                                              context,
                                              widget.quoteId,
                                              'rejected',
                                            ),
                                        isLoading: loading,
                                      ),
                                    ),
                                    16.toWidth,
                                    Expanded(
                                      child: CustomButton(
                                        btText: "Send Quote",
                                        onPressed:
                                            () => aqvm.submitQuoteResponse(
                                              context,
                                              widget.quoteId,
                                              'reviewed',
                                            ),
                                        isLoading: loading,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
