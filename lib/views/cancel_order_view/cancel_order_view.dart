import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/dynamics/cancellation_policy_service.dart';
import 'package:car_service/services/order_services/order_details_service.dart';
import 'package:car_service/services/order_services/refund_settings_service.dart';
import 'package:car_service/utils/components/alerts.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/warning_widget.dart';
import 'package:car_service/view_models/order_details_view_model/order_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../utils/components/custom_dropdown.dart';
import '../../utils/components/custom_future_widget.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/field_with_label.dart';

class CancelOrderView extends StatelessWidget {
  const CancelOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final odm = OrderDetailsViewModel.instance;
    final cps = CancellationPolicyService.instance;
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
                  child: TextFormField(
                    minLines: 3,
                    maxLines: 6,
                    controller: odm.reasonController,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: LocalKeys.bookingNoteExmp,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    onTapOutside: (event) {
                      context.unFocus;
                    },
                  ),
                ),
                16.toHeight,
                FieldLabel(label: LocalKeys.paymentMethods),
                Consumer<RefundSettingsService>(
                  builder: (context, rs, child) {
                    return CustomFutureWidget(
                      function:
                          rs.shouldAutoFetch
                              ? rs.fetchWithdrawSettings()
                              : null,
                      shimmer: const CustomPreloader(),
                      child: ValueListenableBuilder(
                        valueListenable: odm.selectedGateway,
                        builder: (context, gateway, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomDropdown(
                                LocalKeys.selectAPaymentMethod,
                                rs.withdrawSettingsModel.withdrawGateways
                                    .map((e) => e.name)
                                    .toList(),
                                (value) {
                                  odm.setSelectedGateway(rs, value);
                                },
                                value: gateway?.name,
                              ),
                              16.toHeight,
                              if (gateway != null)
                                ...Iterable.generate(gateway.field.length).map((
                                  e,
                                ) {
                                  return FieldWithLabel(
                                        label: gateway.field[e],
                                        hintText:
                                            gateway.field[e]
                                                ?.toString()
                                                .capitalize ??
                                            "",
                                        isRequired: true,
                                        controller:
                                            odm.inputFieldControllers[e],
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return gateway.field[e]
                                                ?.toString()
                                                .capitalize;
                                          }
                                          return null;
                                        },
                                      )
                                      .animate(
                                        delay: (e * 100 as int).milliseconds,
                                      )
                                      .slideY()
                                      .fadeIn();
                                }),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
                CustomButton(
                  onPressed: () {
                    if (odm.selectedGateway.value == null) {
                      LocalKeys.selectAPaymentMethod.showToast();
                      return;
                    }
                    if (!(odm.formKey.currentState?.validate() ?? false)) {
                      debugPrint(
                        (odm.formKey.currentState?.validate()).toString(),
                      );
                      return;
                    }
                    Alerts().confirmationAlert(
                      context: context,
                      title: LocalKeys.areYouSure,
                      onConfirm: () async {
                        final result =
                            await Provider.of<OrderDetailsService>(
                              context,
                              listen: false,
                            ).tryCancelOrder();
                        if (result) {
                          context.pop;
                        }
                        context.pop;
                      },
                    );
                    context.unFocus;
                  },
                  btText: LocalKeys.cancelOrder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
