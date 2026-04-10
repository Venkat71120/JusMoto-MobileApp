import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:car_service/view_models/quote_view_model/quote_view_model.dart';
import 'package:flutter/material.dart';

class CreateQuoteView extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;

  const CreateQuoteView({
    super.key,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  State<CreateQuoteView> createState() => _CreateQuoteViewState();
}

class _CreateQuoteViewState extends State<CreateQuoteView> {
  final qvm = QuoteViewModel.instance;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      qvm.titleController.text = widget.initialTitle!;
    }
    if (widget.initialDescription != null) {
      qvm.descriptionController.text = widget.initialDescription!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request a Quote"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: context.color.cardFillColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: qvm.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What service do you need?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                8.toHeight,
                const Text(
                  "Provide details about the service you are looking for, and our team will get back to you with a quote.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                24.toHeight,

                // ── Title Field ──────────────────────────────────────────────
                FieldWithLabel(
                  label: "Title",
                  hintText: "Enter title (e.g., Car denting repair)",
                  controller: qvm.titleController,
                  isRequired: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Title is required";
                    return null;
                  },
                ),
                16.toHeight,

                // ── Description Field ────────────────────────────────────────
                FieldWithLabel(
                  label: "Description",
                  hintText: "Describe your requirement in detail...",
                  controller: qvm.descriptionController,
                  isRequired: true,
                  minLines: 5,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "Description is required";
                    return null;
                  },
                ),
                40.toHeight,

                // ── Submit Button ────────────────────────────────────────────
                ValueListenableBuilder<bool>(
                  valueListenable: qvm.isLoading,
                  builder: (context, loading, child) {
                    return CustomButton(
                      btText: "Submit Request",
                      onPressed: () => qvm.submitQuoteRequest(context),
                      isLoading: loading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
