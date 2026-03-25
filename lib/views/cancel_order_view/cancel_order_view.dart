import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/dynamics/cancellation_policy_service.dart';
import 'package:car_service/services/order_services/order_details_service.dart';
import 'package:car_service/utils/components/alerts.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/warning_widget.dart';
import 'package:car_service/view_models/order_details_view_model/order_details_view_model.dart';
import 'package:car_service/views/refund_list_view/refund_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CancelOrderView extends StatelessWidget {
  const CancelOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final odm = OrderDetailsViewModel.instance;
    final cps = CancellationPolicyService.instance;
    final odService = Provider.of<OrderDetailsService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalKeys.cancelOrder),
        leading: NavigationPopIcon(backgroundColor: Colors.transparent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SquircleContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: context.color.accentContrastColor,
          radius: 12,
          child: Form(
            key: odm.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((cps.cancellationData.value["description"]?.toString() ??
                        "")
                    .isNotEmpty) ...[
                  WarningWidget(
                    text: cps.cancellationData.value["description"],
                  ),
                  16.toHeight,
                ],
                FieldLabel(label: LocalKeys.reason),
                SquircleContainer(
                  radius: 8,
                  color: context.color.backgroundColor,
                  child: TextFormField(
                    minLines: 3,
                    maxLines: 6,
                    controller: odm.reasonController,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please provide a reason for cancellation";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: LocalKeys.bookingNoteExmp,
                      contentPadding: const EdgeInsets.all(12),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    onTapOutside: (event) {
                      context.unFocus;
                    },
                  ),
                ),
                24.toHeight,
                CustomButton(
                  onPressed: () {
                    if (!(odm.formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    // Capture values before cancel clears the model
                    final isPaid = ["complete", "1"].contains(
                      odService.orderDetailsModel.orderDetails?.paymentStatus
                          ?.toString(),
                    );
                    final orderId = odService.orderDetailsModel.orderDetails?.id
                            ?.toString() ??
                        "";
                    // Capture navigator before pops unmount the context
                    final navigator = Navigator.of(context);
                    Alerts().confirmationAlert(
                      context: context,
                      title: LocalKeys.areYouSure,
                      onConfirm: () async {
                        final result = await odService.tryCancelOrder(
                          orderId: orderId,
                          reason: odm.reasonController.text,
                        );
                        if (result) {
                          odm.reasonController.clear();
                          navigator.pop(); // Pop confirmation
                          navigator.pop(); // Pop CancelOrderView
                          if (isPaid) {
                            navigator.push(MaterialPageRoute(
                              builder: (_) => const RefundListView(),
                            ));
                          }
                        }
                      },
                    );
                    context.unFocus;
                  },
                  btText: LocalKeys.cancelOrder,
                ),
                12.toHeight,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
