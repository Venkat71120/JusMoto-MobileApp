import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../services/profile_services/profile_info_service.dart';
import '../../../utils/components/info_tile.dart';
import '../../../view_models/sign_in_view_model/sign_in_view_model.dart';
import '../../service_booking_address_schedule_view/service_booking_address_schedule_view.dart';
import '../../sign_in_view/sign_in_view.dart';

class CartPriceInfos extends StatelessWidget {
  final CartService cs;
  const CartPriceInfos({super.key, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          padding: 24.paddingH,
          decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Wrap(
            children: [
              Row(
                children: [
                  16.toHeight,
                ],
              ),
              InfoTile(title: LocalKeys.total, value: cs.subTotal.cur),
              Row(
                children: [
                  16.toHeight,
                ],
              ),
            ],
          ),
        ),
        Consumer<ProfileInfoService>(builder: (context, pi, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
                color: context.color.accentContrastColor,
                border: Border(
                    top: BorderSide(color: context.color.primaryBorderColor))),
            child: ElevatedButton(
                onPressed: () {
                  if (pi.profileInfoModel.userDetails == null) {
                    SignInViewModel.dispose;
                    SignInViewModel.instance.initSavedInfo();
                    context.toPage(const SignInView());
                    return;
                  }
                  ServiceBookingViewModel.dispose;
                  context.toPage(const ServiceBookingAddressScheduleView());
                },
                child: Text(pi.profileInfoModel.userDetails == null
                    ? LocalKeys.signIn
                    : LocalKeys.continueO)),
          );
        }),
      ],
    );
  }
}
