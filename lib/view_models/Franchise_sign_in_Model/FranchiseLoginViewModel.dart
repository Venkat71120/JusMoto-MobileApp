import 'package:car_service/customization.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/auth_services/FranchiseLoginService.dart';
import 'package:car_service/view_models/Franchise_landing_view_model/FranchiseLandingViewModel.dart';
import 'package:car_service/views/Franchise_landing_nav_view/FranchiseLandingView.dart';
// import 'package:car_service/views/Franchise_dashboard/franchise_landing_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../services/chat_services/chat_credential_service.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../../services/push_notification_service.dart';
// import '../../view_models/franchise_landing_view_model/franchise_landing_view_model.dart';

class FranchiseLoginViewModel {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> passObs = ValueNotifier(true);
  final ValueNotifier<bool> rememberMe = ValueNotifier(true);

  final GlobalKey<FormState> formKey = GlobalKey();

  final ValueNotifier loading = ValueNotifier<bool>(false);
  bool signInSuccess = false;

  FranchiseLoginViewModel._init();
  static FranchiseLoginViewModel? _instance;
  static FranchiseLoginViewModel get instance {
    _instance ??= FranchiseLoginViewModel._init();
    return _instance!;
  }

  FranchiseLoginViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  setUserInfo({username, pass}) async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        rememberMe.value) {
      sPref?.setString("franchise-username", usernameController.text);
      sPref?.setString("franchise-pass", passwordController.text);
    } else if (rememberMe.value) {
      sPref?.setString("franchise-username", username ?? "");
      sPref?.setString("franchise-pass", pass ?? "");
    } else {
      sPref?.setString("franchise-username", "");
      sPref?.setString("franchise-pass", "");
    }
    sPref?.setBool("franchise-remember", rememberMe.value);
  }

  usernameValidator(value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return asProvider.getString(LocalKeys.usernameRequired);
    }
    return null;
  }

  passwordValidator(value) {
    if (value == null || value.isEmpty) {
      return asProvider.getString(LocalKeys.passwordRequired);
    }
    if (value.length < 8) {
      return LocalKeys.passLeastCharWarning;
    }
    return null;
  }

  initSavedInfo() {
    usernameController.text = sPref?.getString("franchise-username") ?? "";
    passwordController.text = sPref?.getString("franchise-pass") ?? "";
    rememberMe.value = sPref?.getBool("franchise-remember") ?? true;
  }

  franchiseSignIn(BuildContext context) async {
    debugPrint('🔐 Starting franchise sign-in process');

    final isValid = formKey.currentState?.validate();
    if (isValid == false) {
      debugPrint('❌ Form validation failed');
      return;
    }

    loading.value = true;

    try {
      final flProvider =
          Provider.of<FranchiseLoginService>(context, listen: false);
      final piProvider =
          Provider.of<ProfileInfoService>(context, listen: false);

      final result = await flProvider.tryFranchiseLogin(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );

      if (result == true) {
        debugPrint('✅ Franchise login successful');

        await setUserInfo(
          username: usernameController.text,
          pass: passwordController.text,
        );

        Provider.of<ChatCredentialService>(context, listen: false)
            .fetchCredentials();

        signInSuccess = true;

        await PushNotificationService().updateDeviceToken(forceUpdate: true);
        await piProvider.fetchProfileInfo();

        loading.value = false;

        // ✅ Navigate to FranchiseLandingView — clears entire back stack
        if (context.mounted) {
          debugPrint('📍 Navigating to FranchiseLandingView');
          FranchiseLandingViewModel.instance.currentIndex.value = 0;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const FranchiseLandingView(),
            ),
            (route) => false, // removes ALL previous routes
          );
        }
      } else if (result == false) {
        debugPrint('❌ Franchise login rejected by server');
        loading.value = false;
        LocalKeys.invalidFranchiseCredentials.showToast();
      } else {
        debugPrint('❌ Franchise login returned null');
        loading.value = false;
      }
    } catch (e) {
      debugPrint('❌ Exception during franchise sign-in: $e');
      loading.value = false;
      LocalKeys.signInFailed.showToast();
    }
  }

  clearFields() {
    usernameController.clear();
    passwordController.clear();
  }
}