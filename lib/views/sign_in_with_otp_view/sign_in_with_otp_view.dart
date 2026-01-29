import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/sign_in_with_otp_view_model/sign_in_with_otp_view_model.dart';
import 'package:flutter/material.dart';

class SignInWithOtpView extends StatelessWidget {
  const SignInWithOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final sio = SignInWithOtpViewModel.instance;
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: const NavigationPopIcon(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: sio.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalKeys.otpSignIn,
                style: context.titleLarge?.bold,
              ),
              32.toHeight,
              FieldWithLabel(
                label: LocalKeys.phone,
                hintText: "+8801938000000",
                isRequired: true,
                keyboardType: TextInputType.number,
                controller: sio.phoneController,
                validator: (value) {
                  if (value.toString().length < 5) {
                    return LocalKeys.enterAValidPhoneNumber;
                  }
                  return null;
                },
              ),
              12.toHeight,
              ValueListenableBuilder(
                valueListenable: sio.isLoading,
                builder: (context, value, child) => CustomButton(
                  onPressed: () {
                    sio.trySignIn(context);
                  },
                  btText: LocalKeys.continueO,
                  isLoading: value,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
