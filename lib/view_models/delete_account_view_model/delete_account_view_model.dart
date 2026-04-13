import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/profile_services/delete_account_service.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/utils/components/alerts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountViewModel {
  TextEditingController currentPassController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  ValueNotifier<bool> currentPassObs = ValueNotifier(true);
  ValueNotifier<Reason?> selectedReason = ValueNotifier(null);

  final GlobalKey<FormState> formKey = GlobalKey();

  DeleteAccountViewModel._init();
  static DeleteAccountViewModel? _instance;
  static DeleteAccountViewModel get instance {
    _instance ??= DeleteAccountViewModel._init();
    return _instance!;
  }

  DeleteAccountViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void tryDeletingAccount(BuildContext context) async {
    final valid = formKey.currentState?.validate();
    if (valid != true) return;
    
    if (selectedReason.value == null) {
      LocalKeys.selectAReason.showToast();
      return;
    }
    Alerts().confirmationAlert(
        context: context,
        title: LocalKeys.areYouSure,
        onConfirm: () async {
          await Provider.of<DeleteAccountService>(context, listen: false)
              .tryDeletingAccount()
              .then((v) {
            if (v != true) return;
            Provider.of<ProfileInfoService>(context, listen: false).reset();
            context.pop;
            context.pop;
          });
        },
        buttonColor: context.color.primaryWarningColor,
        buttonText: LocalKeys.delete);
  }
}
