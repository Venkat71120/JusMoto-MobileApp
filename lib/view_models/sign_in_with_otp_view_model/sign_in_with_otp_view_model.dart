import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/phone_field.dart';
import '../../services/auth_services/phone_manage_service.dart';
import '../../views/sign_in_with_otp_view/phone_otp_view.dart';

class SignInWithOtpViewModel {
  final TextEditingController phoneController = TextEditingController();

  final ValueNotifier<Phone?> phone = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final GlobalKey<FormState> formKey = GlobalKey();

  SignInWithOtpViewModel._init();
  static SignInWithOtpViewModel? _instance;
  static SignInWithOtpViewModel get instance {
    _instance ??= SignInWithOtpViewModel._init();
    return _instance!;
  }

  SignInWithOtpViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void trySignIn(BuildContext context) async {
    if (formKey.currentState!.validate() != true) return;
    isLoading.value = true;
    try {
      final otpResult =
          await Provider.of<PhoneManageService>(context, listen: false)
              .tryOtpToPhone(phone: phoneController.text);
      if (otpResult == true) {
        final vResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneOtpView(),
            ));
        if (vResult == true) {
          await Provider.of<ProfileInfoService>(context, listen: false)
              .fetchProfileInfo();
          context.pop;
          context.pop;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
