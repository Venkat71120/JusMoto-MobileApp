import 'package:car_service/helper/extension/context_extension.dart';
import 'package:flutter/material.dart';

import '../../services/profile_services/change_password_service.dart';

class ChangePasswordViewModel {
  TextEditingController currentPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();

  ValueNotifier<bool> currentPassObs = ValueNotifier(true);
  ValueNotifier<bool> newPassObs = ValueNotifier(true);
  ValueNotifier<bool> cNewPassObs = ValueNotifier(true);
  ValueNotifier<bool> loading = ValueNotifier(false);

  final GlobalKey<FormState> formKey = GlobalKey();

  ChangePasswordViewModel._init();
  static ChangePasswordViewModel? _instance;
  static ChangePasswordViewModel get instance {
    _instance ??= ChangePasswordViewModel._init();
    return _instance!;
  }

  ChangePasswordViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void tryToChangePassword(BuildContext context) async {
    final valid = formKey.currentState?.validate();
    if (valid != true) {
      return;
    }
    loading.value = true;
    try {
      await ChangePasswordService().tryChangingPassword().then((result) {
        if (result == true) {
          context.popFalse;
        }
      });
    } finally {
      loading.value = false;
    }
  }
}
