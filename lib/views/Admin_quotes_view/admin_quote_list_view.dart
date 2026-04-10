import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';

import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/view_models/admin_view_models/admin_quote_view_model.dart';
import 'package:car_service/views/Admin_quotes_view/admin_quote_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/quote_services/quote_service.dart';

class AdminQuoteListView extends StatefulWidget {
  const AdminQuoteListView({super.key});

  @override
  State<AdminQuoteListView> createState() => _AdminQuoteListViewState();
}

class _AdminQuoteListViewState extends State<AdminQuoteListView> {
  final aqvm = AdminQuoteViewModel.instance;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      aqvm.fetchAllQuotes(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Quote Requests"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: CustomRefreshIndicator(
              onRefresh:
                  () => aqvm.fetchAllQuotes(context, status: selectedStatus),
              child: Consumer<QuoteService>(
                builder: (context, qs, child) {
                  return CustomFutureWidget(
                    isLoading: qs.loading,
                    child:
                        qs.quoteList.data.isEmpty
                            ? const Center(
                              child: EmptyWidget(
                                title: "No quote requests found",
                              ),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: qs.quoteList.data.length,
                              separatorBuilder: (context, index) => 12.toHeight,
                              itemBuilder: (context, index) {
                                final quote = qs.quoteList.data[index];
                                return _AdminQuoteCard(quote: quote);
                              },
                            ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final statuses = [
      {'label': 'All', 'value': null},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Reviewed', 'value': 'reviewed'},
      {'label': 'Rejected', 'value': 'rejected'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (context, index) => 8.toWidth,
        itemBuilder: (context, index) {
          final s = statuses[index];
          final isSelected = selectedStatus == s['value'];
          return FilterChip(
            label: Text(s['label'] as String),
            selected: isSelected,
            onSelected: (val) {
              setState(() {
                selectedStatus = s['value'];
              });
              aqvm.fetchAllQuotes(context, status: selectedStatus);
            },
            selectedColor: context.color.primaryPendingColor.withOpacity(0.2),
            labelStyle: TextStyle(
              color:
                  isSelected ? context.color.primaryPendingColor : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}

class _AdminQuoteCard extends StatelessWidget {
  final dynamic quote;
  const _AdminQuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.orange;
    if (quote.status.toLowerCase() == 'reviewed') statusColor = Colors.green;
    if (quote.status.toLowerCase() == 'rejected') statusColor = Colors.red;

    return InkWell(
      onTap: () {
        context.toPage(AdminQuoteDetailsView(quoteId: quote.id));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quote.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  quote.createdAt.toString().split('T')[0],
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
            8.toHeight,
            Text(
              quote.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            4.toHeight,
            Text(
              quote.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            if (quote.quotedPrice != null) ...[
              12.toHeight,
              Text(
                "Quoted: ₹${quote.quotedPrice}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
