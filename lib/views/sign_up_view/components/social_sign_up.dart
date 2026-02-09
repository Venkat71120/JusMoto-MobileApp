import 'dart:io';

import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';

import '../../../view_models/sign_up_view_model/social_sign_in_view_model.dart';
import '../../sign_in_view/components/social_sign_in_button.dart';

class SocialSignUp extends StatelessWidget {
  const SocialSignUp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ssi = SocialSignInViewModel.instance;
    return Column(
      spacing: 16,
      children: [
        SocialSignInButton(
          title: LocalKeys.signUpWithGoogle,
          image: "google",
          onTap: () async {
            await ssi.trySocialSignIn(context);
          },
        ),
        // SocialSignInButton(
        //   title: LocalKeys.signUpWithFacebook,
        //   image: "facebook",
        //   onTap: () async {
        //     await ssi.trySocialSignIn(context, type: "facebook");
        //   },
        // ),
        if (Platform.isIOS)
          SocialSignInButton(
            title: LocalKeys.signUpWithApple,
            image: "apple",
            onTap: () async {
              await ssi.trySocialSignIn(context, type: "apple");
            },
          ),
      ],
    );
  }
}
