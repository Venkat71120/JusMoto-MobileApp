import 'package:car_service/customizations/colors.dart';
import 'package:car_service/views/sign_up_view/sign_up_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';
import '/helper/local_keys.g.dart';
import '../../../view_models/sign_up_view_model/sign_up_view_model.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        softWrap: true,
        text: TextSpan(
            text: LocalKeys.doNotHaveAccount,
            style: context.bodyMedium,
            children: [
              const TextSpan(
                text: '   ',
              ),
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      FocusScope.of(context).unfocus();
                      SignUpViewModel.dispose;
                      context.toPage(const SignUpView());
                    },
                  text: LocalKeys.signUp,
                  style: const TextStyle(color: primaryColor)),
            ]),
      ),
    );
  }
}
