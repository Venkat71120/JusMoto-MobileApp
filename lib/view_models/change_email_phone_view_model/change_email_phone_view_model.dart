import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_services/phone_manage_service.dart';
import './../../services/auth_services/email_otp_service.dart';
import './../../views/change_email_view/change_email_otp_view.dart';
import './../../views/change_phone_view/change_phone_otp_view.dart';

class ChangeEmailPhoneViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final GlobalKey<FormState> mailForm = GlobalKey();

  ChangeEmailPhoneViewModel._init();
  static ChangeEmailPhoneViewModel? _instance;
  static ChangeEmailPhoneViewModel get instance {
    _instance ??= ChangeEmailPhoneViewModel._init();
    return _instance!;
  }

  ChangeEmailPhoneViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void tryChangingEmail(BuildContext context) async {
    if (mailForm.currentState!.validate() != true) return;
    isLoading.value = true;
    try {
      final otpResult =
          await Provider.of<EmailManageService>(context, listen: false)
              .tryOtpToNewEmail(emailUsername: emailController.text);
      if (otpResult == true) {
        final verifyResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeEmailOtpView(null),
            ));
        if (verifyResult == true) {
          context.pop;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void tryChangingPhone(BuildContext context) async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      "Please enter a phone number".showToast();
      return;
    }
    if (phone.length < 10) {
      "Please enter a valid phone number".showToast();
      return;
    }
    isLoading.value = true;
    try {
      final otpResult =
          await Provider.of<PhoneManageService>(context, listen: false)
              .trySendingOtpToNewPhone(phone: phoneController.text);
      if (otpResult == true) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePhoneOtpView(),
            ));
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
