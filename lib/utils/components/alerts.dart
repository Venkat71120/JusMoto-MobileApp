import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';
import '/utils/components/custom_preloader.dart';
import '/utils/components/empty_spacer_helper.dart';
import '../../customizations/colors.dart';
import '../../helper/local_keys.g.dart';

class Alerts {
  confirmationAlert({
    required BuildContext context,
    required String title,
    String? description,
    String? buttonText,
    required Future Function() onConfirm,
    Color? buttonColor,
  }) async {
    ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
    await showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: context.width - 80,
              decoration: BoxDecoration(
                color: context.color.accentContrastColor,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(maxWidth: 480),
              child: Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Text(title, style: context.titleLarge?.bold6),
                      ),
                      EmptySpaceHelper.emptyHeight(4),
                      Center(
                        child: Text(
                          description ?? '',
                          style: context.bodyMedium,
                        ),
                      ),
                      12.toHeight,
                      Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: OutlinedButton(
                              onPressed: () {
                                context.popFalse;
                              },
                              child: Text(
                                LocalKeys.cancel,
                                style: context.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          16.toWidth,
                          ValueListenableBuilder(
                            valueListenable: loadingNotifier,
                            builder: (context, value, child) {
                              return Expanded(
                                flex: 8,
                                child: CustomButton(
                                  onPressed: () {
                                    loadingNotifier.value = true;
                                    onConfirm().then(
                                      (value) => loadingNotifier.value = false,
                                    );
                                  },
                                  backgroundColor:
                                      buttonColor ??
                                      context.color.primaryWarningColor,
                                  btText: buttonText ?? "Confirm",
                                  isLoading: value,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  normalAlert({
    required BuildContext context,
    required String title,
    String? description,
    String? buttonText,
    required Future Function() onConfirm,
    Color? buttonColor,
  }) async {
    ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: context.width - 80,
              decoration: BoxDecoration(
                color: context.color.accentContrastColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20),
                    children: [
                      SizedBox(
                        height: 52,
                        child: Image.asset("assets/images/success.png"),
                      ),
                      16.toHeight,
                      Center(
                        child: Text(title, style: context.titleMedium?.bold6),
                      ),
                      8.toHeight,
                      Center(
                        child: Text(
                          description ?? '',
                          textAlign: TextAlign.center,
                          style: context.titleSmall,
                        ),
                      ),
                      20.toHeight,
                      Row(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: loadingNotifier,
                            builder: (context, value, child) {
                              return Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    loadingNotifier.value = true;
                                    onConfirm().then(
                                      (value) => loadingNotifier.value = false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        buttonColor ??
                                        context.color.primaryWarningColor,
                                  ),
                                  child:
                                      value
                                          ? const SizedBox(
                                            height: 40,
                                            child: CustomPreloader(
                                              whiteColor: true,
                                            ),
                                          )
                                          : Text(
                                            buttonText ?? "Confirm",
                                            style: context.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  context
                                                      .color
                                                      .accentContrastColor,
                                            ),
                                          ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  showInfoDialogue({
    required BuildContext context,
    required String title,
    String? description,
    Widget? infoAsset,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: context.width - 80,
              decoration: BoxDecoration(
                color: context.color.accentContrastColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (infoAsset != null) ...[
                        Stack(
                          children: [
                            Center(child: SizedBox(child: infoAsset)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.pop;
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: context.color.primaryContrastColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        16.toHeight,
                      ],
                      Center(
                        child: Text(title, style: context.titleMedium?.bold6),
                      ),
                      8.toHeight,
                      Center(
                        child: Text(
                          description ?? '',
                          textAlign: TextAlign.center,
                          style: context.titleSmall?.copyWith(
                            color: context.color.tertiaryContrastColo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  showLoading({required BuildContext context}) async {
    ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
    await showDialog(
      context: context,
      builder: (context) {
        return Material(
          color: context.color.primaryContrastColor.withOpacity(.7),
          child: const Center(child: CustomPreloader()),
        );
      },
    );
  }

  static showPopupMenu(
    BuildContext context,
    TapDownDetails details,
    Map itemMap,
    Function(Object?) onValue,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items:
          itemMap.entries.map((entry) {
            return PopupMenuItem(value: entry.key, child: Text(entry.value));
          }).toList(),
    ).then((value) {
      onValue(value);
    });
  }

  paymentFailWarning(BuildContext context, {onFailed}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(LocalKeys.areYouSure),
          content: Text(LocalKeys.yourPaymentWillTerminate),
          actions: [
            TextButton(
              onPressed: onFailed ?? () {},
              child: Text(
                LocalKeys.yes,
                style: const TextStyle(color: primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
