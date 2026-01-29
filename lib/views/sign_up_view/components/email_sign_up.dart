import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/view_models/sign_up_view_model/sign_up_view_model.dart';
import 'package:flutter/material.dart';

import '../../../helper/local_keys.g.dart';
import '../../../utils/components/field_with_label.dart';
import '../../../utils/components/pass_field_with_label.dart';
import 'accepted_agreement.dart';

class EmailSignUp extends StatelessWidget {
  const EmailSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final sum = SignUpViewModel.instance;
    return AutofillGroup(
      child: Form(
        key: sum.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldWithLabel(
              label: LocalKeys.email,
              hintText: LocalKeys.enterEmail,
              isRequired: true,
              controller: sum.emailController,
              autofillHints: const [AutofillHints.email],
              validator: (email) {
                return !email.toString().validateEmail
                    ? LocalKeys.enterValidEmailAddress
                    : null;
              },
            ),
            PassFieldWithLabel(
              label: LocalKeys.password,
              hintText: LocalKeys.enterPassword,
              isRequired: true,
              valueListenable: sum.passObs,
              controller: sum.passwordController,
              autofillHints: const [AutofillHints.newPassword],
              validator: (pass) {
                return pass.toString().validPass;
              },
            ),
            PassFieldWithLabel(
              label: LocalKeys.confirmPassword,
              hintText: LocalKeys.retypePassword,
              isRequired: true,
              valueListenable: sum.passConfirmObs,
              validator: (v) {
                if (sum.passwordController.text != v) {
                  return LocalKeys.passwordDidNotMatch;
                }
              },
            ),
            16.toHeight,
            const AcceptedAgreement(),
            16.toHeight,
            ValueListenableBuilder(
                valueListenable: sum.loading,
                builder: (context, loading, child) {
                  return CustomButton(
                    onPressed: () {
                      sum.tryEmailSignUp(context);
                    },
                    btText: LocalKeys.signUp,
                    isLoading: loading,
                  );
                })
          ],
        ),
      ),
    );
  }
}
