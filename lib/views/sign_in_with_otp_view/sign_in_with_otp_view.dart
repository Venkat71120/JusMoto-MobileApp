import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
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
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.signInWithMobileNumber),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: sio.formKey,
          child: SquircleContainer(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: context.color.accentContrastColor,
            radius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.toHeight,
                Text(
                  LocalKeys.verificationCodeWillBeSentToTheNewPhone,
                  style: context.bodyMedium,
                ),
                24.toHeight,
                FieldWithLabel(
                  label: LocalKeys.phone,
                  hintText: LocalKeys.phoneNumberHint,
                  controller: sio.phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  isRequired: true,
                  validator: (value) {
                    if (value.toString().length < 5) {
                      return LocalKeys.enterAValidPhoneNumber;
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: sio.isLoading,
          builder: (context, value, child) => CustomButton(
            onPressed: () {
              sio.trySignIn(context);
            },
            btText: LocalKeys.sendVerificationCode,
            isLoading: value,
          ),
        ),
      ),
    );
  }
}
