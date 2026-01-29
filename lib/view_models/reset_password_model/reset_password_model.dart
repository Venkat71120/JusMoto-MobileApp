import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/helper/extension/context_extension.dart';
import '../../services/auth_services/email_otp_service.dart';
import '../../services/reset_password_service.dart';
import '../../views/reset_password/enter_otp_view.dart';
import '../../views/reset_password/new_password_view.dart';

class ResetPasswordViewModel {
  TextEditingController emailController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  ValueNotifier obscurePassNew = ValueNotifier(true);
  ValueNotifier obscurePassCon = ValueNotifier(true);
  ValueNotifier loadingResetPassword = ValueNotifier(false);
  final GlobalKey<FormState> emailFormKey = GlobalKey();
  final GlobalKey<FormState> passwordFormKey = GlobalKey();

  ResetPasswordViewModel._init();
  static ResetPasswordViewModel? _instance;
  static ResetPasswordViewModel get instance {
    _instance ??= ResetPasswordViewModel._init();
    return _instance!;
  }

  ResetPasswordViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  trySendingOTP(BuildContext context) async {
    final valid = emailFormKey.currentState!.validate();
    if (!valid) {
      return;
    }
    final otpProvider = Provider.of<EmailManageService>(context, listen: false);
    var result =
        await otpProvider.tryOtpToEmail(emailUsername: emailController.text);

    if (result == true) {
      final otpResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterOtpView(
                Provider.of<EmailManageService>(context, listen: false).otp,
                email: emailController.text,
                fromRegister: true),
          ));
      if (otpResult != true) {
        debugPrint(otpResult.toString());
      } else {
        context.toPage(NewPasswordView(
          otp: Provider.of<EmailManageService>(context, listen: false).otp,
        ));
      }
    }
  }

  tryResetPassword(BuildContext context, otp) async {
    final valid = passwordFormKey.currentState!.validate();
    if (!valid) {
      return;
    }
    loadingResetPassword.value = true;
    await Provider.of<ResetPasswordService>(context, listen: false)
        .resetPassword(
            context, emailController.text, newPassController.text, otp)
        .then((value) {
      if (value == true) {
        context.popTrue;
        context.popTrue;
      }
    });
    loadingResetPassword.value = false;
  }
}
