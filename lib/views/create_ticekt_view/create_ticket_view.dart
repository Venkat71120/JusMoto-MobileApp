import 'package:car_service/app_static_values.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_dropdown.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/support_services/ticket_list_service.dart';
import '../../utils/components/custom_button.dart';
import '../../utils/components/custom_future_widget.dart';
import '../../utils/components/custom_preloader.dart';
import '../../view_models/create_ticket_view_model/create_ticket_view_model.dart';

class CreateTicketView extends StatelessWidget {
  const CreateTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctm = CreateTicketViewModel.instance;
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.createTicket),
      ),
      body: SingleChildScrollView(
          child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: context.color.cardFillColor,
        child: Form(
            key: ctm.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldWithLabel(
                  label: LocalKeys.title,
                  hintText: LocalKeys.enterTitle,
                  controller: ctm.titleController,
                  isRequired: true,
                  validator: (title) {
                    if (title!.isEmpty || title.trim().length < 4) {
                      return LocalKeys.ticketTittleLeastChar;
                    }
                    return null;
                  },
                ),
                FieldLabel(
                  label: LocalKeys.department,
                  isRequired: true,
                ),
                Consumer<TicketListService>(
                    builder: (context, tlProvider, child) {
                  return CustomFutureWidget(
                    function: 1 == 1 ? tlProvider.fetchDepartments() : null,
                    shimmer: const CustomPreloader(),
                    child: ValueListenableBuilder(
                      valueListenable: ctm.selectedDepartment,
                      builder: (context, value, child) {
                        return CustomDropdown(
                          LocalKeys.selectDepartment,
                          (tlProvider.departments
                                  ?.map((e) => e.name ?? "")
                                  .toList()) ??
                              [],
                          (value) {
                            ctm.selectedDepartment.value =
                                tlProvider.departments?.firstWhere(
                                    (element) => element.name == value);
                          },
                          value: value?.name,
                        );
                      },
                    ),
                  );
                }),
                FieldLabel(
                  label: LocalKeys.priority,
                  isRequired: true,
                ),
                ValueListenableBuilder(
                  valueListenable: ctm.selectedPriority,
                  builder: (context, value, child) {
                    return CustomDropdown(
                      LocalKeys.selectPriority,
                      priorityList,
                      (priority) {
                        ctm.selectedPriority.value = priority;
                      },
                      value: value,
                    );
                  },
                ),
                FieldWithLabel(
                  label: LocalKeys.description,
                  hintText: LocalKeys.enterDescription,
                  controller: ctm.descriptionController,
                  minLines: 6,
                  textInputAction: TextInputAction.newline,
                  validator: (description) {
                    if (description!.isEmpty || description.trim().isEmpty) {
                      return LocalKeys.enterDescription;
                    }
                    return null;
                  },
                ),
              ],
            )),
      )),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            border: Border(
                top: BorderSide(color: context.color.primaryBorderColor))),
        child: ValueListenableBuilder(
            valueListenable: ctm.isLoading,
            builder: (context, laoding, child) {
              return CustomButton(
                onPressed: () {
                  ctm.tryCreatingTicket(context);
                },
                btText: LocalKeys.createTicket,
                isLoading: laoding,
              );
            }),
      ),
    );
  }
}
