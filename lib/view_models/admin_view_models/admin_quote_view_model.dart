import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/quote_services/quote_service.dart';

class AdminQuoteViewModel extends ChangeNotifier {
  final TextEditingController priceController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  AdminQuoteViewModel._init();
  static AdminQuoteViewModel? _instance;
  static AdminQuoteViewModel get instance {
    _instance ??= AdminQuoteViewModel._init();
    return _instance!;
  }

  void disposeViewModel() {
    priceController.clear();
    noteController.clear();
    isLoading.value = false;
    _instance = null;
  }

  Future<void> fetchAllQuotes(
    BuildContext context, {
    int page = 1,
    String? status,
  }) async {
    final quoteService = Provider.of<QuoteService>(context, listen: false);
    await quoteService.fetchAllQuotes(page: page, status: status);
  }

  Future<void> fetchQuoteDetails(BuildContext context, int id) async {
    final quoteService = Provider.of<QuoteService>(context, listen: false);
    await quoteService.fetchQuoteDetails(id);

    // Pre-fill fields if quote was already reviewed
    final quote = quoteService.quoteDetail;
    if (quote != null) {
      if (quote.quotedPrice != null) {
        priceController.text = quote.quotedPrice.toString();
      }
      if (quote.adminNote != null) {
        noteController.text = quote.adminNote!;
      }
    }
  }

  Future<void> submitQuoteResponse(
    BuildContext context,
    int id,
    String status,
  ) async {
    final isValid = formKey.currentState?.validate();
    if (isValid == false && status == 'reviewed') return;

    isLoading.value = true;
    final quoteService = Provider.of<QuoteService>(context, listen: false);

    double? price = double.tryParse(priceController.text);

    final success = await quoteService.updateQuoteResponse(
      id: id,
      status: status,
      quotedPrice: price,
      adminNote: noteController.text,
    );

    isLoading.value = false;

    if (success) {
      context.pop;
      "Quote updated successfully".showToast();
      // Refresh the list
      quoteService.fetchAllQuotes(page: 1);
    } else {
      "Failed to update quote".showToast();
    }
  }
}
