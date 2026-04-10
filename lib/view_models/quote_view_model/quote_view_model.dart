import 'package:car_service/helper/extension/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/quote_services/quote_service.dart';

class QuoteViewModel extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  QuoteViewModel._init();
  static QuoteViewModel? _instance;
  static QuoteViewModel get instance {
    _instance ??= QuoteViewModel._init();
    return _instance!;
  }

  void disposeViewModel() {
    titleController.clear();
    descriptionController.clear();
    isLoading.value = false;
    _instance = null;
  }

  Future<void> submitQuoteRequest(BuildContext context) async {
    final isValid = formKey.currentState?.validate();
    if (isValid == false) return;

    isLoading.value = true;
    final quoteService = Provider.of<QuoteService>(context, listen: false);

    final success = await quoteService.createQuoteRequest(
      title: titleController.text,
      description: descriptionController.text,
      type: "service",
    );

    isLoading.value = false;

    if (success) {
      disposeViewModel();
      context.popFalse;
      // Refresh the quote list if the user is on the list view
      quoteService.fetchMyQuotes(page: 1);
    }
  }

  Future<void> fetchMyQuotes(BuildContext context, {int page = 1}) async {
    final quoteService = Provider.of<QuoteService>(context, listen: false);
    await quoteService.fetchMyQuotes(page: page);
  }

  Future<void> fetchQuoteDetails(BuildContext context, int id) async {
    final quoteService = Provider.of<QuoteService>(context, listen: false);
    await quoteService.fetchQuoteDetails(id);
  }
}
