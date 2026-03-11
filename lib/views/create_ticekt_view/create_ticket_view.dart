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

import '../../utils/components/custom_preloader.dart';
import '../../view_models/create_ticket_view_model/create_ticket_view_model.dart';

class CreateTicketView extends StatefulWidget {
  const CreateTicketView({super.key});

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketListService>(context, listen: false).fetchDepartments();
    });
  }

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
                  // Still loading
                  if (tlProvider.departments == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CustomPreloader(),
                    );
                  }
                  // Failed to load or empty — show retry button
                  if (tlProvider.departments!.isEmpty) {
                    return TextButton.icon(
                      onPressed: () {
                        tlProvider.fetchDepartments();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry loading departments"),
                    );
                  }
                  // Data available — show dropdown
                  return ValueListenableBuilder(
                    valueListenable: ctm.selectedDepartment,
                    builder: (context, value, child) {
                      // Deduplicate names to prevent DropdownButton from throwing an error
                      // if the backend returns multiple departments with the same name or nulls.
                      final Set<String> uniqueNames = {};
                      for (var dept in tlProvider.departments!) {
                        final name = dept.name == null || dept.name!.isEmpty 
                             ? "Department ${dept.id ?? 'Unknown'}" 
                             : dept.name!;
                        uniqueNames.add(name);
                      }

                      return CustomDropdown(
                        LocalKeys.selectDepartment,
                        uniqueNames.toList(),
                        (selected) {
                          ctm.selectedDepartment.value =
                              tlProvider.departments?.firstWhere(
                                  (element) {
                                    final name = element.name == null || element.name!.isEmpty 
                                        ? "Department ${element.id ?? 'Unknown'}" 
                                        : element.name!;
                                    return name == selected;
                                  },
                                  orElse: () => tlProvider.departments!.first);
                        },
                        value: value?.name == null || value!.name!.isEmpty 
                            ? (value?.id != null ? "Department ${value!.id}" : null)
                            : value.name,
                      );
                    },
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
