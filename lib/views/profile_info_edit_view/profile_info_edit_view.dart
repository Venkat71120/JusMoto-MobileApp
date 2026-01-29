import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';

import '../../utils/components/custom_squircle_widget.dart';
import '../../view_models/profile_edit_view_model/profile_edit_view_model.dart';

class ProfileInfoEditView extends StatelessWidget {
  const ProfileInfoEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final pem = ProfileEditViewModel.instance;
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.personalInformation),
      ),
      body: SingleChildScrollView(
          child: SquircleContainer(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: context.color.accentContrastColor,
        radius: 12,
        child: Form(
          key: pem.basicFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.toHeight,
              FieldWithLabel(
                label: LocalKeys.firstName,
                hintText: LocalKeys.enterFirstName,
                controller: pem.fNameController,
                isRequired: true,
                validator: (value) {
                  if ((value ?? "").isEmpty) {
                    return LocalKeys.enterAValidName;
                  }
                  return null;
                },
              ),
              FieldWithLabel(
                label: LocalKeys.lastName,
                hintText: LocalKeys.enterLastName,
                controller: pem.lNameController,
                isRequired: true,
                validator: (value) {
                  if ((value ?? "").isEmpty) {
                    return LocalKeys.enterAValidName;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      )),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            border: Border(
                top: BorderSide(color: context.color.primaryBorderColor))),
        child: ValueListenableBuilder(
            valueListenable: pem.isLoading,
            builder: (context, value, child) {
              return CustomButton(
                onPressed: () {
                  if (!(pem.basicFormKey.currentState!.validate())) return;

                  pem.updateBasicInfo(context);
                },
                btText: LocalKeys.saveChanges,
                isLoading: value,
              );
            }),
      ),
    );
  }
}
