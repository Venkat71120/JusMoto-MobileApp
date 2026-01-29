import 'dart:io';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/auth_services/sign_up_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_static_values.dart';
import '../../helper/local_keys.g.dart';
import '../../services/auth_services/email_otp_service.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../../utils/components/alerts.dart';
import '../../views/landing_view/landing_view.dart';
import '../../views/reset_password/enter_otp_view.dart';
import '../../views/sign_up_view/sign_up_name_date.dart';
import '../sign_in_view_model/sign_in_view_model.dart';

class SignUpViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  bool signUpSuccess = false;

  final ValueNotifier<bool> passObs = ValueNotifier(true);
  final ValueNotifier<bool> passConfirmObs = ValueNotifier(true);
  final ValueNotifier<bool> rememberPass = ValueNotifier(true);
  final ValueNotifier<bool> loading = ValueNotifier(false);
  final ValueNotifier<bool> profileSetupLoading = ValueNotifier(false);
  final ValueNotifier<File?> profileImage = ValueNotifier(null);
  final ValueNotifier<DateTime?> dob = ValueNotifier(null);

  final GlobalKey<FormState> formKey = GlobalKey();
  final GlobalKey<FormState> piFormKey = GlobalKey();
  final ValueNotifier<List<dynamic>> categories = ValueNotifier([]);

  SignUpViewModel._init();
  static SignUpViewModel? _instance;
  static SignUpViewModel get instance {
    _instance ??= SignUpViewModel._init();
    return _instance!;
  }

  SignUpViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  tryEmailSignUp(BuildContext context) async {
    final isValid = formKey.currentState?.validate();

    if (isValid == false) {
      return;
    }

    final sim = SignInViewModel.instance;
    loading.value = true;
    final siProvider = Provider.of<SignUpService>(context, listen: false);
    final piProvider = Provider.of<ProfileInfoService>(context, listen: false);
    final sResult = await siProvider.tryEmailSignUp(
      emailUsername: emailController.text,
      password: passwordController.text,
    );
    if (sResult == true) {
      signUpSuccess = true;
    } else if (sResult == null) {
      signUpSuccess = false;
    } else {
      final su = Provider.of<SignUpService>(context, listen: false);
      final result = await Provider.of<EmailManageService>(
        context,
        listen: false,
      ).tryOtpToEmail(emailUsername: emailController.text);
      if (result == true) {
        final otpResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => EnterOtpView(
                  Provider.of<EmailManageService>(context, listen: false).otp,
                  email: su.email,
                  fromRegister: true,
                ),
          ),
        );
        if (otpResult != true) {
          debugPrint(otpResult.toString());
          await Alerts().showInfoDialogue(
            context: context,
            title: LocalKeys.verificationFailed,
            description: LocalKeys.accountCreatedButVerificationFailed,
          );
          context.pop;
          signUpSuccess = false;
        } else {
          final verifyResult = await Provider.of<EmailManageService>(
            context,
            listen: false,
          ).tryEmailVerify(
            emailUsername: emailController.text,
            userId: su.userId,
            token: su.token,
          );
          if (verifyResult == true) {
            signUpSuccess = true;
          }
        }
      }
    }

    debugPrint("Sign up success is $signUpSuccess".toString());
    if (!signUpSuccess) {
      loading.value = false;
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpNameDate()),
    );
    if (rememberPass.value == true) {
      sim.setUserInfo(
        email: emailController.text,
        pass: passwordController.text,
      );
    } else {
      sim.setUserInfo();
    }
    loading.value = false;
  }

  void selectProfileImage() async {
    try {
      FilePickerResult? file = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["jpg", "png", "jpeg"],
      );
      if (file?.files.firstOrNull?.path == null) {
        return;
      }
      final File imageFile = File(file!.paths.first!);
      num maxSize = 1024 * 1024 * (profileImageMaxSize ?? 1); // 1MB
      final num fileSize = await imageFile.length();

      if (fileSize > maxSize) {
        LocalKeys.fileSizeExceeded.showToast();
        return;
      }
      profileImage.value = File(file.files.first.path!);
      LocalKeys.fileSelected.showToast();
    } catch (error) {
      LocalKeys.fileSelectFailed.showToast();
    }
  }

  void tryToSetProfileInfo(BuildContext context) async {
    profileSetupLoading.value = true;
    final result =
        await Provider.of<SignUpService>(
          context,
          listen: false,
        ).tryToSetProfileInfos();
    if (result == true) {
      Provider.of<ProfileInfoService>(
        context,
        listen: false,
      ).fetchProfileInfo().then((v) {
        if (v != true) return;
        try {
          SignInViewModel.instance.setUserInfo(
            email:
                emailController.text.isNotEmpty ? emailController.text : null,
            pass:
                passwordController.text.isNotEmpty
                    ? passwordController.text
                    : null,
          );
        } catch (e) {}
        context.toUntilPage(const LandingView());
      });
    }
    profileSetupLoading.value = false;
  }
}
