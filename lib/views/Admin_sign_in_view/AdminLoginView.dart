import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/pass_field_with_label.dart';
import 'package:car_service/view_models/Admin_sign_in_Model/AdminLoginViewModel.dart';
import 'package:flutter/material.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final alm = AdminLoginViewModel.instance;

  @override
  void initState() {
    super.initState();
    alm.initSavedInfo();
  }

  @override
  void dispose() {
    AdminLoginViewModel.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: const Text('Admin Login'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: AutofillGroup(
            child: Form(
              key: alm.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Admin Portal Access',
                    style: context.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  8.toHeight,
                  Text(
                    'Login to manage the platform',
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
                    controller: alm.usernameController,
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return alm.usernameValidator(value ?? "");
                    },
                  ),

                  // Password Field
                  PassFieldWithLabel(
                    label: LocalKeys.password,
                    hintText: LocalKeys.enterPassword,
                    valueListenable: alm.passObs,
                    controller: alm.passwordController,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) {
                      return alm.passwordValidator(value) as String?;
                    },
                    onFieldSubmitted: (_) {
                      alm.adminSignIn(context);
                    },
                  ),

                  // Remember Me Checkbox
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: alm.rememberMe,
                          builder: (context, value, child) {
                            return Row(
                              children: [
                                Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: value,
                                    onChanged: (newValue) {
                                      alm.rememberMe.value = newValue ?? false;
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
                    valueListenable: alm.loading,
                    builder: (context, loading, child) {
                      return CustomButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          alm.adminSignIn(context);
                        },
                        btText: 'Sign in to Admin',
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
                          Icons.admin_panel_settings,
                          color: primaryColor,
                          size: 24,
                        ),
                        12.toWidth,
                        Expanded(
                          child: Text(
                            'Administrative privileges are required to access this portal.',
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
