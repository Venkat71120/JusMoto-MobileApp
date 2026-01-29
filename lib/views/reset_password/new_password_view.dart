import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '/helper/local_keys.g.dart';
import '/view_models/reset_password_model/reset_password_model.dart';
import '../../helper/svg_assets.dart';
import '../../utils/components/custom_button.dart';
import '../../utils/components/pass_field_with_label.dart';

class NewPasswordView extends StatelessWidget {
  final otp;
  const NewPasswordView({super.key, required this.otp});

  @override
  Widget build(BuildContext context) {
    final rp = ResetPasswordViewModel.instance;
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.resetPassword.capitalizeWords),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: context.color.accentContrastColor,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: LottieBuilder.asset(
                "assets/animations/lock.json",
                height: 200,
              ),
            ),
            Form(
                key: rp.passwordFormKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PassFieldWithLabel(
                        label: LocalKeys.newPassword,
                        hintText: LocalKeys.enterPassword,
                        valueListenable: rp.obscurePassNew,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        controller: rp.newPassController,
                        svgPrefix: SvgAssets.lock,
                      ),
                      PassFieldWithLabel(
                        label: LocalKeys.confirmPassword,
                        hintText: LocalKeys.retypePassword,
                        valueListenable: rp.obscurePassCon,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        controller: TextEditingController(),
                        svgPrefix: SvgAssets.lock,
                        validator: (value) {
                          if (rp.newPassController.text != value) {
                            return LocalKeys.passwordDidNotMatch;
                          }
                          return null;
                        },
                      ),
                    ])),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            border: Border(
                top: BorderSide(color: context.color.primaryBorderColor))),
        child: ValueListenableBuilder(
          valueListenable: rp.loadingResetPassword,
          builder: (context, value, child) => CustomButton(
            onPressed: () {
              rp.tryResetPassword(context, otp);
            },
            btText: LocalKeys.setNewPassword,
            isLoading: value,
          ),
        ),
      ),
    );
  }
}
