import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../services/profile_services/profile_info_service.dart';
import '../../../view_models/sign_in_view_model/sign_in_view_model.dart';
import '../../service_booking_address_schedule_view/service_booking_address_schedule_view.dart';
import '../../sign_in_view/sign_in_view.dart';

class CartPriceInfos extends StatelessWidget {
  final CartService cs;
  const CartPriceInfos({super.key, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.accentContrastColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.color.primaryBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Price summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.color.mutedContrastColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    14.toWidth,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalKeys.total,
                            style: context.bodySmall?.copyWith(
                              color: context.color.tertiaryContrastColo,
                              fontSize: 12,
                            ),
                          ),
                          2.toHeight,
                          Text(
                            cs.subTotal.cur,
                            style: context.titleLarge?.bold.price.copyWith(
                              fontSize: 22,
                              color: context.color.primaryContrastColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Item count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${cs.cartList.length} ${cs.cartList.length == 1 ? 'item' : 'items'}",
                        style: context.bodySmall?.bold6.copyWith(
                          color: primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              16.toHeight,
              // Checkout button
              Consumer<ProfileInfoService>(
                builder: (context, pi, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (pi.profileInfoModel.userDetails == null) {
                          SignInViewModel.dispose;
                          SignInViewModel.instance.initSavedInfo();
                          context.toPage(const SignInView());
                          return;
                        }
                        ServiceBookingViewModel.dispose;
                        context.toPage(
                            const ServiceBookingAddressScheduleView());
                      },
                      icon: Icon(
                        pi.profileInfoModel.userDetails == null
                            ? Icons.login_rounded
                            : Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                      label: Text(
                        pi.profileInfoModel.userDetails == null
                            ? LocalKeys.signIn
                            : LocalKeys.continueO,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
