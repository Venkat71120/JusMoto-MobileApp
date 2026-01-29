import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../models/support_models/ticket_list_model.dart';
import '../../services/support_services/ticket_create_service.dart';
import '../../services/support_services/ticket_list_service.dart';

class CreateTicketViewModel {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  ValueNotifier<Department?> selectedDepartment = ValueNotifier(null);
  ValueNotifier<String?> selectedPriority = ValueNotifier("High");
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  final GlobalKey<FormState> formKey = GlobalKey();

  CreateTicketViewModel._init();
  static CreateTicketViewModel? _instance;
  static CreateTicketViewModel get instance {
    _instance ??= CreateTicketViewModel._init();
    return _instance!;
  }

  CreateTicketViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void tryCreatingTicket(BuildContext context) async {
    final valid = formKey.currentState?.validate();
    final isValid = formKey.currentState?.validate();
    if (isValid == false) {
      return;
    }
    if (selectedDepartment.value == null) {
      LocalKeys.selectDepartment.showToast();
      return;
    }
    if (selectedPriority.value == null) {
      LocalKeys.selectPriority.showToast();
      return;
    }

    isLoading.value = true;

    final ctProvider = TicketCreateService();

    ctProvider
        .createTicket(
            title: titleController.text,
            description: descriptionController.text,
            priority: selectedPriority.value.toString(),
            selectedDepartment: selectedDepartment.value!)
        .then((v) async {
      if (v == true) {
        await Provider.of<TicketListService>(context, listen: false)
            .fetchTicketList();
        dispose;
        context.popFalse;
        isLoading.value = false;
      }
      isLoading.value = false;
    });
  }
}
