import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/pass_field_with_label.dart';
import 'package:car_service/view_models/change_password_view_model/change_password_view_model.dart';
import 'package:flutter/material.dart';

import '../../utils/components/custom_button.dart';
import '../../utils/components/custom_squircle_widget.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final cpm = ChangePasswordViewModel.instance;
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.changePassword),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SquircleContainer(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: context.color.accentContrastColor,
            radius: 12,
            child: Form(
              key: cpm.formKey,
              child: Column(
                children: [
                  16.toHeight,
                  PassFieldWithLabel(
                    label: LocalKeys.currentPassword,
                    hintText: LocalKeys.enterYourCurrentPassword,
                    controller: cpm.currentPassController,
                    valueListenable: cpm.currentPassObs,
                    autofillHints: const [AutofillHints.password],
                    validator: (pass) {
                      if (pass.toString().length < 8) {
                        return LocalKeys.passLeastCharWarning;
                      }
                    },
                  ),
                  PassFieldWithLabel(
                    label: LocalKeys.newPassword,
                    hintText: LocalKeys.enterNewPassword,
                    controller: cpm.newPassController,
                    valueListenable: cpm.newPassObs,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (pass) {
                      return pass.toString().validPass;
                    },
                  ),
                  PassFieldWithLabel(
                    label: LocalKeys.confirmPassword,
                    hintText: LocalKeys.reEnterNewPassword,
                    controller: TextEditingController(),
                    valueListenable: cpm.cNewPassObs,
                    validator: (v) {
                      if (v.toString() != cpm.newPassController.text) {
                        return LocalKeys.passwordDidNotMatch;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        child: ValueListenableBuilder(
          valueListenable: cpm.loading,
          builder: (context, loading, child) => CustomButton(
            onPressed: () {
              cpm.tryToChangePassword(context);
            },
            btText: LocalKeys.saveChanges,
            isLoading: loading,
          ),
        ),
      ),
    );
  }
}
