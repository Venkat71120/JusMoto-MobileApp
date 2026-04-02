import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/view_models/sign_in_view_model/sign_in_view_model.dart';
import 'package:car_service/view_models/sign_in_with_otp_view_model/sign_in_with_otp_view_model.dart';
import 'package:car_service/views/sign_in_view/components/remember_password.dart';
import 'package:car_service/views/sign_in_with_otp_view/sign_in_with_otp_view.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';
import '../../../helper/local_keys.g.dart';
import '../../../utils/components/field_with_label.dart';
import '../../../utils/components/pass_field_with_label.dart';
import 'forgot_password.dart';

class EmailSignIn extends StatelessWidget {
  const EmailSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    final sim = SignInViewModel.instance;
    return AutofillGroup(
      child: Form(
        key: sim.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: LocalKeys.email,
                      style: context.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: " *",
                          style: context.titleMedium?.copyWith(
                            color: context.color.primaryWarningColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      SignInWithOtpViewModel.dispose;
                      context.toPage(const SignInWithOtpView());
                    },
                    child: Text(
                      LocalKeys.signInWithMobileNumber,
                      style: context.bodySmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FieldWithLabel(
              label: null,
              hintText: LocalKeys.enterEmail,
              isRequired: true,
              controller: sim.emailController,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                return sim.emailUsernameValidator(value ?? "");
              },
            ),
            PassFieldWithLabel(
              label: LocalKeys.password,
              hintText: LocalKeys.enterPassword,
              valueListenable: sim.passObs,
              controller: sim.passwordController,
              autofillHints: const [AutofillHints.password],
              validator: (value) {
                if (value.toString().length < 8) {
                  return LocalKeys.passLeastCharWarning;
                }
              },
              onFieldSubmitted: (_) {
                sim.signIn(context);
              },
            ),
            Row(
              children: [
                Expanded(
                    child: RememberPassword(rememberPass: sim.rememberPass)),
                12.toWidth,
                const ForgotPassword(),
              ],
            ),
            24.toHeight,
            ValueListenableBuilder(
              valueListenable: sim.loading,
              builder: (context, loading, child) {
                return CustomButton(
                  onPressed: () {
                    sim.signIn(context);
                  },
                  btText: LocalKeys.signIn,
                  isLoading: loading,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
