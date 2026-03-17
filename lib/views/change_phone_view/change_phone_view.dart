import 'package:flutter/material.dart';

import '../../utils/components/custom_button.dart';
import '../../utils/components/custom_squircle_widget.dart';
import './../../helper/extension/context_extension.dart';
import './../../helper/extension/int_extension.dart';
import './../../helper/local_keys.g.dart';
import './../../utils/components/field_with_label.dart';
import './../../utils/components/navigation_pop_icon.dart';
import './../../view_models/change_email_phone_view_model/change_email_phone_view_model.dart';

class ChangePhoneView extends StatelessWidget {
  const ChangePhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final cep = ChangeEmailPhoneViewModel.instance;
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.changePhone),
      ),
      body: SingleChildScrollView(
        child: SquircleContainer(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: context.color.accentContrastColor,
            radius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.toHeight,
                Text(
                  LocalKeys.verificationCodeWillBeSentToTheNewPhone,
                  style: context.bodyMedium,
                ),
                24.toHeight,
                FieldWithLabel(
                  label: LocalKeys.phone,
                  hintText: LocalKeys.phoneNumberHint,
                  controller: cep.phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                )
              ],
            )),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        child: ValueListenableBuilder(
          valueListenable: cep.isLoading,
          builder: (context, value, child) => CustomButton(
            onPressed: () {
              cep.tryChangingPhone(context);
            },
            btText: LocalKeys.sendVerificationCode,
            isLoading: value,
          ),
        ),
      ),
    );
  }
}
