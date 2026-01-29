import 'package:car_service/customization.dart';
import 'package:car_service/customizations/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '/helper/extension/context_extension.dart';
import '/helper/local_keys.g.dart';

class TacPp extends StatelessWidget {
  final ValueNotifier<bool> valueListenable;

  const TacPp({
    super.key,
    required this.valueListenable,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<bool>(
            valueListenable: valueListenable,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  value: valueListenable.value,
                  onChanged: (newValue) {
                    valueListenable.value = newValue ?? !value;
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 10,
          child: RichText(
            softWrap: true,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                text: '${LocalKeys.byCreatingAnAccountYouAgreeToThe} ',
                style: TextStyle(
                  color: context.color.secondaryContrastColor,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          FocusScope.of(context).unfocus();
                          await urlLauncher
                              .launch("$siteLink/terms-conditions");
                        },
                      text: LocalKeys.termsAndConditions,
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      )),
                  TextSpan(
                      text: ' ${LocalKeys.and} ',
                      style: TextStyle(
                          color: context.color.secondaryContrastColor)),
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          FocusScope.of(context).unfocus();
                          await urlLauncher.launch("$siteLink/privacy-policy");
                        },
                      text: LocalKeys.privacyPolicy,
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      )),
                ]),
          ),
        ),
      ],
    );
  }
}
