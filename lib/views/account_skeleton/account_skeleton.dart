import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../view_models/sign_in_view_model/sign_in_view_model.dart';
import '../sign_in_view/sign_in_view.dart';

class AccountSkeleton extends StatelessWidget {
  const AccountSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieBuilder.asset(
            "assets/animations/sign_in.json",
            fit: BoxFit.cover,
            repeat: false,
          ),
          SizedBox(
            width: 300,
            child: CustomButton(
              onPressed: () {
                SignInViewModel.dispose;
                SignInViewModel.instance.initSavedInfo();
                context.toPage(const SignInView());
              },
              btText: LocalKeys.signIn,
              isLoading: false,
            ),
          )
        ],
      ),
    );
  }
}
