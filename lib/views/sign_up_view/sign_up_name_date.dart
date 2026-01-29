import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/sign_up_view_model/sign_up_view_model.dart';
import 'package:flutter/material.dart';

import 'upload_profile_image_view.dart';

class SignUpNameDate extends StatelessWidget {
  const SignUpNameDate({super.key});

  @override
  Widget build(BuildContext context) {
    final sum = SignUpViewModel.instance;
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: const NavigationPopIcon(),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: sum.piFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            12.toHeight,
            Text(
              LocalKeys.aboutYou,
              style: context.labelLarge?.bold,
            ),
            4.toHeight,
            Text(
              LocalKeys.aboutYouDesc,
              style: context.bodyMedium,
            ),
            32.toHeight,
            FieldWithLabel(
              label: LocalKeys.firstName,
              hintText: LocalKeys.enterFirstName,
              controller: sum.fNameController,
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
              controller: sum.lNameController,
              isRequired: true,
              validator: (value) {
                if ((value ?? "").isEmpty) {
                  return LocalKeys.enterAValidName;
                }
                return null;
              },
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    if (!(sum.piFormKey.currentState!.validate())) return;

                    context.toPage(const UploadProfileImageView());
                  },
                  child: Text(
                    LocalKeys.continueO,
                  )),
            )
          ],
        ).hp20,
      )),
    );
  }
}
