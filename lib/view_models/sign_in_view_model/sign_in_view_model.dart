import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../services/auth_services/email_otp_service.dart';
import '../../services/auth_services/sign_in_service.dart';
import '../../services/auth_services/sign_up_service.dart';
import '../../services/chat_services/chat_credential_service.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../../services/push_notification_service.dart';
import '../../views/reset_password/enter_otp_view.dart';
import '../../views/sign_up_view/sign_up_name_date.dart';

class SignInViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> passObs = ValueNotifier(true);
  final ValueNotifier<bool> rememberPass = ValueNotifier(true);
  final GlobalKey<FormState> formKey = GlobalKey();
  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);

  bool signInSuccess = false;

  SignInViewModel._init();
  static SignInViewModel? _instance;
  static SignInViewModel get instance {
    _instance ??= SignInViewModel._init();
    return _instance!;
  }

  SignInViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  // ─── Validators ──────────────────────────────────────────────────────────

  String? emailUsernameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocalKeys.emailUsernameValidateText;
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocalKeys.passwordRequired;
    }
    return null;
  }

  // ─── Persist / restore credentials ───────────────────────────────────────

  void initSavedInfo() {
    emailController.text = sPref?.getString("user-email") ?? "";
    passwordController.text = sPref?.getString("user-pass") ?? "";
    rememberPass.value = sPref?.getBool("user-remember") ?? false;
  }

  void setUserInfo({String? email, String? pass}) {
    if (rememberPass.value) {
      sPref?.setString("user-email", email ?? emailController.text);
      sPref?.setString("user-pass", pass ?? passwordController.text);
    } else {
      sPref?.setString("user-email", "");
      sPref?.setString("user-pass", "");
    }
    sPref?.setBool("user-remember", rememberPass.value);
  }

  // ─── Sign in ──────────────────────────────────────────────────────────────

  /// Attempts email/username + password sign-in.
  ///
  /// Result from [SignInService.trySignIn]:
  ///   true  → credentials valid AND email verified (or verify disabled)
  ///   false → credentials valid BUT email not yet verified → trigger OTP flow
  ///   null  → wrong credentials or server error
  Future<void> signIn(BuildContext context) async {
    if (formKey.currentState?.validate() != true) return;

    loading.value = true;

    final siService = Provider.of<SignInService>(context, listen: false);
    final piService = Provider.of<ProfileInfoService>(context, listen: false);

    final result = await siService.trySignIn(
      emailUsername: emailController.text,
      password: passwordController.text,
    );

    if (!context.mounted) {
      loading.value = false;
      return;
    }

    if (result == true) {
      // ── Fully authenticated ──
      setUserInfo();
      setToken(siService.token);
      setLoginTimestamp();

      if (siService.firstName == null) {
        // Profile incomplete — send to name/date setup
        Provider.of<SignUpService>(context, listen: false)
            .sToken(siService.token);
        await context.toPage(const SignUpNameDate());
        loading.value = false;
        return;
      }

      Provider.of<ChatCredentialService>(context, listen: false)
          .fetchCredentials();
      signInSuccess = true;
      await PushNotificationService().updateDeviceToken(forceUpdate: true);
      await piService.fetchProfileInfo();
      loading.value = false;
      context.popFalse;

    } else if (result == false) {
      // ── Email not verified — trigger OTP verification ──
      final otpSent =
          await Provider.of<EmailManageService>(context, listen: false)
              .tryOtpToEmail(emailUsername: emailController.text);

      if (!context.mounted) {
        loading.value = false;
        return;
      }

      if (otpSent == true) {
        final otpResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterOtpView(
              Provider.of<EmailManageService>(context, listen: false).otp,
              email: emailController.text,
              fromRegister: true,
            ),
          ),
        );

        if (otpResult == true && context.mounted) {
          final verified =
              await Provider.of<EmailManageService>(context, listen: false)
                  .tryEmailVerify(
                emailUsername: emailController.text,
                userId: siService.userId,
                token: siService.token,
              );

          if (verified == true && context.mounted) {
            Provider.of<SignUpService>(context, listen: false)
                .sToken(siService.token);
            await context.toPage(const SignUpNameDate());
          }
        }
      }

      loading.value = false;

    } else {
      // ── Wrong credentials or server error ──
      loading.value = false;
    }
  }
}