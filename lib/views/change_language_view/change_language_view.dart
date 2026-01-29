import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/dynamics/dynamics_service.dart';
import 'package:car_service/utils/components/custom_dropdown.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_preloader.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/constant_helper.dart';
import '../../services/app_string_service.dart';
import '../../utils/components/custom_button.dart';
import '../../utils/components/custom_refresh_indicator.dart';
import '../../utils/components/custom_squircle_widget.dart';
import '../../view_models/change_language_view_model/change_language_view_model.dart';
import '../landing_view/landing_view.dart';

class ChangeLanguageView extends StatelessWidget {
  const ChangeLanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    final clm = ChangeLanguageViewModel.instance;
    return Consumer<AppStringService>(
      builder: (context, as, child) {
        return Consumer<DynamicsService>(
          builder: (context, ds, child) {
            return Scaffold(
              appBar: AppBar(
                leading: const NavigationPopIcon(),
                title: Text(as.getString(LocalKeys.languages)),
              ),
              body: CustomRefreshIndicator(
                onRefresh: () async {
                  await Provider.of<DynamicsService>(
                    context,
                    listen: false,
                  ).getLangList();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SquircleContainer(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    color: context.color.accentContrastColor,
                    radius: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalKeys.changeLanguage,
                          style: context.headlineLarge?.bold,
                        ),
                        24.toHeight,
                        FieldLabel(label: LocalKeys.language),
                        CustomFutureWidget(
                          function:
                              ds.shouldAutoFetch ? ds.getLangList() : null,
                          shimmer: const CustomPreloader(),
                          child: ValueListenableBuilder(
                            valueListenable: clm.selectedLang,
                            builder:
                                (context, value, child) => CustomDropdown(
                                  LocalKeys.selectLanguage,
                                  ds.languageListModel.language
                                          ?.map((l) => l.name!)
                                          .toList() ??
                                      [],
                                  (lang) {
                                    clm.selectedLang.value = lang;
                                  },
                                  value: value ?? ds.localLang,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: ValueListenableBuilder(
                valueListenable: clm.selectedLang,
                builder:
                    (context, value, child) =>
                        clm.selectedLang.value != null &&
                                clm.selectedLang.value != ds.localSlug
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: context.color.accentContrastColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: ValueListenableBuilder(
                                valueListenable: clm.isLoading,
                                builder:
                                    (context, loading, child) => CustomButton(
                                      onPressed: () async {
                                        try {
                                          clm.isLoading.value = true;
                                          if (clm.selectedLang.value != null) {
                                            debugPrint(
                                              "changing lang".toString(),
                                            );
                                            final newLang = ds
                                                .languageListModel
                                                .language
                                                ?.firstWhere(
                                                  (l) =>
                                                      l.name ==
                                                      clm.selectedLang.value,
                                                );
                                            ds.setLangSlug(
                                              newLang?.slug ??
                                                  "${ds.localSlug}",
                                              newLang?.direction != "ltr",
                                              setLocally: true,
                                            );
                                            await Provider.of<AppStringService>(
                                                  context,
                                                  listen: false,
                                                )
                                                .translateStrings(
                                                  context,
                                                  forceChange: true,
                                                )
                                                .then((r) {
                                                  if (r != true) return;
                                                  coreInit(context);
                                                  LocalKeys
                                                      .languageChangesSuccessfully
                                                      .showToast();
                                                  context.toUntilPage(
                                                    const LandingView(),
                                                  );
                                                });
                                          } else {}
                                        } finally {
                                          clm.isLoading.value = false;
                                        }
                                      },
                                      btText: LocalKeys.saveChanges,
                                      isLoading: loading,
                                    ),
                              ),
                            )
                            : const SizedBox(),
              ),
            );
          },
        );
      },
    );
  }
}
