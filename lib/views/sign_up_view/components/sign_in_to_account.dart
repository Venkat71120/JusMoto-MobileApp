import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';
import '/helper/local_keys.g.dart';

class SignInToAccount extends StatelessWidget {
  const SignInToAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        softWrap: true,
        text: TextSpan(
            text: LocalKeys.haveAccount,
            style: TextStyle(
              color: context.color.secondaryContrastColor,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                  text: '   ',
                  style:
                      TextStyle(color: context.color.secondaryContrastColor)),
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
                  text: LocalKeys.signIn.capitalize,
                  style: const TextStyle(color: primaryColor)),
            ]),
      ),
    );
  }
}
