import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/view_models/quote_view_model/quote_view_model.dart';
import 'package:car_service/views/quote_view/quote_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/quote_services/quote_service.dart';

class QuoteListView extends StatefulWidget {
  const QuoteListView({super.key});

  @override
  State<QuoteListView> createState() => _QuoteListViewState();
}

class _QuoteListViewState extends State<QuoteListView> {
  final qvm = QuoteViewModel.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      qvm.fetchMyQuotes(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Quotes"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: CustomRefreshIndicator(
        onRefresh: () => qvm.fetchMyQuotes(context),
        child: Consumer<QuoteService>(
          builder: (context, qs, child) {
            return CustomFutureWidget(
              isLoading: qs.loading,
              child:
                  qs.quoteList.data.isEmpty
                      ? const Center(
                        child: EmptyWidget(title: "No quotes found"),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: qs.quoteList.data.length,
                        separatorBuilder: (context, index) => 12.toHeight,
                        itemBuilder: (context, index) {
                          final quote = qs.quoteList.data[index];
                          return _QuoteCard(quote: quote);
                        },
                      ),
            );
          },
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final dynamic quote;
  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.orange;
    if (quote.status.toLowerCase() == 'reviewed') statusColor = Colors.green;
    if (quote.status.toLowerCase() == 'rejected') statusColor = Colors.red;

    return InkWell(
      onTap: () {
        context.toPage(QuoteDetailsView(quoteId: quote.id));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quote.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
              ],
            ),
            8.toHeight,
            Text(
              quote.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            16.toHeight,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quote.createdAt.toString().split('T')[0],
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
                if (quote.quotedPrice != null)
                  Text(
                    "Price: ₹${quote.quotedPrice}",
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  )
                else
                  const Text(
                    "Price: TBD",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
