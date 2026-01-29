import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/views/sign_up_view/components/email_sign_up.dart';
import 'package:car_service/views/sign_up_view/components/sign_in_to_account.dart';
import 'package:flutter/material.dart';

import 'components/social_sign_up.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.signUp),
        backgroundColor: context.color.accentContrastColor,
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: 8.paddingV,
          child: Container(
            color: context.color.accentContrastColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const EmailSignUp(),
                24.toHeight,
                const SignInToAccount(),
                24.toHeight,
                Row(
                  children: [
                    Expanded(flex: 1, child: const SizedBox().divider),
                    Padding(
                      padding: 6.paddingH,
                      child: Text(
                        LocalKeys.or.toUpperCase(),
                        style: context.titleSmall?.bold,
                      ),
                    ),
                    Expanded(flex: 1, child: const SizedBox().divider),
                  ],
                ),
                24.toHeight,
                const SocialSignUp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
