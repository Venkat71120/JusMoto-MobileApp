import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/Franchise_sign_in_Model/FranchiseLoginViewModel.dart';
import 'package:car_service/view_models/sign_in_with_otp_view_model/sign_in_with_otp_view_model.dart';
import 'package:car_service/views/Franchise_sign_in_view/FranchiseLoginView.dart';
import 'package:car_service/views/sign_in_view/components/email_sign_in.dart';
import 'package:car_service/views/sign_in_view/components/social_sign_in_button.dart';
import 'package:flutter/material.dart';

// import '../../view_models/franchise_login_view_model/franchise_login_view_model.dart';
// import '../franchise/franchise_login_view.dart';
import '../sign_in_with_otp_view/sign_in_with_otp_view.dart';
import 'components/create_account.dart';
import 'components/social_sign_in.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: const NavigationPopIcon(),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                LocalKeys.welcomeBack,
                style: context.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              8.toHeight,
              Text(
                LocalKeys.signIn,
                style: context.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              24.toHeight,

              const EmailSignIn(),
              12.toHeight,
              
              // ✅ NEW: Franchise Login Button
              SocialSignInButton(
                title: LocalKeys.franchiseLogin,
                image: 'lock' , 
                onTap: () {
                  FocusScope.of(context).unfocus();
                  FranchiseLoginViewModel.dispose;
                  context.toPage(const FranchiseLoginView());
                },
              ),
              
              12.toHeight,
              
              // Optional: Uncomment if you want OTP sign-in
              // SocialSignInButton(
              //     title: LocalKeys.otpSignIn,
              //     image: null,
              //     onTap: () {
              //       SignInWithOtpViewModel.dispose;
              //       context.toPage(const SignInWithOtpView());
              //     }),
              
              24.toHeight,
              const CreateAccount(),
              24.toHeight,
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: const SizedBox().divider,
                  ),
                  Padding(
                    padding: 6.paddingH,
                    child: Text(
                      LocalKeys.or.toUpperCase(),
                      style: context.titleSmall?.bold,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: const SizedBox().divider,
                  ),
                ],
              ),
              24.toHeight,
              const SocialSignIn()
            ],
          ),
        ),
      ),
    );
  }
}