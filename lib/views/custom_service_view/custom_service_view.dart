import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/custom_service_request_service.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/views/custom_service_view/my_service_requests_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomServiceView extends StatefulWidget {
  const CustomServiceView({super.key});

  @override
  State<CustomServiceView> createState() => _CustomServiceViewState();
}

class _CustomServiceViewState extends State<CustomServiceView> {
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final service =
        Provider.of<CustomServiceRequestService>(context, listen: false);

    final success = await service.createRequest(
      description: _descriptionController.text.trim(),
    );

    if (success && mounted) {
      _descriptionController.clear();
      // Refresh the requests list and navigate to it
      await service.fetchRequests();
      if (mounted) {
        context.toPage(const MyServiceRequestsView());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: const Text("Custom Service"),
        actions: [
          TextButton(
            onPressed: () {
              context.toPage(const MyServiceRequestsView());
            },
            child: Text(
              "My Requests",
              style: context.bodySmall?.copyWith(
                color: context.color.primaryContrastColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8, bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: context.color.cardFillColor,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Describe Your Service",
                  style: context.titleMedium?.bold,
                ),
                8.toHeight,
                Text(
                  "Tell us what service you need and we'll get back to you with a quote.",
                  style: context.bodySmall?.copyWith(
                    color: context.color.secondaryContrastColor,
                  ),
                ),
                20.toHeight,
                TextFormField(
                  controller: _descriptionController,
                  minLines: 6,
                  maxLines: 10,
                  textInputAction: TextInputAction.newline,
                  style: context.titleSmall,
                  decoration: const InputDecoration(
                    hintText: "Describe the service you need in detail...",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please describe the service you need";
                    }
                    if (value.trim().length < 10) {
                      return "Please provide more details (at least 10 characters)";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          border: Border(
            top: BorderSide(color: context.color.primaryBorderColor),
          ),
        ),
        child: Consumer<CustomServiceRequestService>(
          builder: (context, service, child) {
            return CustomButton(
              onPressed: getToken.isEmpty ? null : _submitRequest,
              btText: "Get Quote",
              isLoading: service.isSubmitting,
            );
          },
        ),
      ),
    );
  }
}
