import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/services/order_services/order_details_service.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../customizations/colors.dart';
import '../../../helper/local_keys.g.dart';
import '../../../view_models/service_booking_view_model/service_booking_view_model.dart';
import '../../booking_payment_choose_view/booking_payment_choose_view.dart';

class PayAgainButton extends StatelessWidget {
  const PayAgainButton({super.key});

  @override
  Widget build(BuildContext context) {
    final sm = ServiceBookingViewModel.instance;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          border:
              Border(top: BorderSide(color: context.color.primaryBorderColor))),
      child: ValueListenableBuilder(
        valueListenable: sm.isLoading,
        builder: (context, value, child) => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ServiceBookingViewModel.dispose;
              ServiceBookingViewModel.instance.setPayableAmount(
                  Provider.of<OrderDetailsService>(context, listen: false)
                          .orderDetailsModel
                          .orderDetails
                          ?.total ??
                      0,
                  Provider.of<OrderDetailsService>(context, listen: false)
                      .orderDetailsModel
                      .orderDetails
                      ?.id);
              debugPrint(getToken.toString());
              context.toPage(const BookingPaymentChooseView(payAgain: true));
            },
            label: Text(LocalKeys.payNow),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                return mutedPrimaryColor;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return context.color.secondaryContrastColor;
                }

                return primaryColor;
              }),
              shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((states) {
                return SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 12,
                    cornerSmoothing: 1,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
