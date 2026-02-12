import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/pass_field_with_label.dart';
import 'package:car_service/view_models/Franchise_sign_in_Model/FranchiseLoginViewModel.dart';
import 'package:flutter/material.dart';

class FranchiseLoginView extends StatefulWidget {
  const FranchiseLoginView({super.key});

  @override
  State<FranchiseLoginView> createState() => _FranchiseLoginViewState();
}

class _FranchiseLoginViewState extends State<FranchiseLoginView> {
  final flm = FranchiseLoginViewModel.instance;

  @override
  void initState() {
    super.initState();
    flm.initSavedInfo();
  }

  @override
  void dispose() {
    FranchiseLoginViewModel.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.franchiseLogin),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: AutofillGroup(
            child: Form(
              key: flm.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    LocalKeys.franchiseLoginTitle,
                    style: context.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  8.toHeight,
                  Text(
                    LocalKeys.franchiseLoginSubtitle,
                    style: context.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  24.toHeight,

                  // Username Field
                  FieldWithLabel(
                    label: LocalKeys.username,
                    hintText: LocalKeys.enterUsername,
                    isRequired: true,
                    controller: flm.usernameController,
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return flm.usernameValidator(value ?? "");
                    },
                  ),

                  // Password Field
                  PassFieldWithLabel(
                    label: LocalKeys.password,
                    hintText: LocalKeys.enterPassword,
                    valueListenable: flm.passObs,
                    controller: flm.passwordController,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) {
                      return flm.passwordValidator(value) as String?;
                    },
                    onFieldSubmitted: (_) {
                      flm.franchiseSignIn(context);
                    },
                  ),

                  // Remember Me Checkbox
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: flm.rememberMe,
                          builder: (context, value, child) {
                            return Row(
                              children: [
                                Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: value,
                                    onChanged: (newValue) {
                                      flm.rememberMe.value = newValue ?? false;
                                    },
                                  ),
                                ),
                                4.toWidth,
                                Expanded(
                                  child: Text(
                                    LocalKeys.rememberMe,
                                    style: context.titleMedium,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  24.toHeight,

                  // Login Button
                  ValueListenableBuilder(
                    valueListenable: flm.loading,
                    builder: (context, loading, child) {
                      return CustomButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          flm.franchiseSignIn(context);
                        },
                        btText: LocalKeys.franchiseLogin,
                        isLoading: loading,
                      );
                    },
                  ),

                  24.toHeight,

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: primaryColor,
                          size: 24,
                        ),
                        12.toWidth,
                        Expanded(
                          child: Text(
                            LocalKeys.franchiseLoginInfo,
                            style: context.bodySmall?.copyWith(
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}