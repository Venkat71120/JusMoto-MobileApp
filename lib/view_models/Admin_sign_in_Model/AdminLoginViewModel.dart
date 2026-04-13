import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/auth_services/AdminLoginService.dart';
import 'package:car_service/view_models/Admin_landing_view_model/AdminLandingViewModel.dart';
import 'package:car_service/views/Admin_landing_nav_view/AdminLandingView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../services/chat_services/chat_credential_service.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../../services/push_notification_service.dart';

class AdminLoginViewModel {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> passObs = ValueNotifier(true);
  final ValueNotifier<bool> rememberMe = ValueNotifier(true);

  final GlobalKey<FormState> formKey = GlobalKey();

  final ValueNotifier loading = ValueNotifier<bool>(false);
  bool signInSuccess = false;

  AdminLoginViewModel._init();
  static AdminLoginViewModel? _instance;
  static AdminLoginViewModel get instance {
    _instance ??= AdminLoginViewModel._init();
    return _instance!;
  }

  AdminLoginViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  setUserInfo({username, pass}) async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        rememberMe.value) {
      sPref?.setString("admin-username", usernameController.text);
      sPref?.setString("admin-pass", passwordController.text);
    } else if (rememberMe.value) {
      sPref?.setString("admin-username", username ?? "");
      sPref?.setString("admin-pass", pass ?? "");
    } else {
      sPref?.setString("admin-username", "");
      sPref?.setString("admin-pass", "");
    }
    sPref?.setBool("admin-remember", rememberMe.value);
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
    usernameController.text = sPref?.getString("admin-username") ?? "";
    passwordController.text = sPref?.getString("admin-pass") ?? "";
    rememberMe.value = sPref?.getBool("admin-remember") ?? true;
  }

  adminSignIn(BuildContext context) async {
    debugPrint('🔐 Starting admin sign-in process');

    final isValid = formKey.currentState?.validate();
    if (isValid == false) {
      debugPrint('❌ Form validation failed');
      return;
    }

    loading.value = true;

    try {
      final alProvider =
          Provider.of<AdminLoginService>(context, listen: false);
      final piProvider =
          Provider.of<ProfileInfoService>(context, listen: false);

      final result = await alProvider.tryAdminLogin(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );

      if (result == true) {
        debugPrint('✅ Admin login successful');

        await setUserInfo(
          username: usernameController.text,
          pass: passwordController.text,
        );

        Provider.of<ChatCredentialService>(context, listen: false)
            .fetchCredentials();

        signInSuccess = true;

        await PushNotificationService().updateDeviceToken(forceUpdate: true);
        // User profile fetch skipped for admin accounts
        // await piProvider.fetchProfileInfo();

        loading.value = false;

        // Navigate to AdminLandingView — clears entire back stack
        if (context.mounted) {
          debugPrint('📍 Navigating to AdminLandingView');
          AdminLandingViewModel.instance.currentIndex.value = 0;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminLandingView(),
            ),
            (route) => false, // removes ALL previous routes
          );
        }
      } else {
        // ERROR CASE: The result is already handled within the Service via tosh (showToast)
        // or it returned false/null due to an error.
        debugPrint('❌ Admin login failed - result: $result');
        loading.value = false;
        // The Service itself shows the specific error toast (e.g. "Not an admin").
        // We only show a fallback if result was definitively false without a message.
        if (result == false && !context.mounted) {
             // Already handled by service.showToast()
        }
      }
    } catch (e) {
      debugPrint('❌ Exception during admin sign-in: $e');
      loading.value = false;
      "Sign in failed: $e".showToast();
    }
  }

  clearFields() {
    usernameController.clear();
    passwordController.clear();
  }
}
