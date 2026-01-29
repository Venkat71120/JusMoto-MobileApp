import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../helper/app_urls.dart';
import '../../../helper/local_keys.g.dart';
import '../../tac_pp_view/tac_pp_view.dart';

class AcceptedAgreement extends StatelessWidget {
  const AcceptedAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      softWrap: true,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
          text: '${LocalKeys.byProceedingIAgreeToThe} ',
          style: TextStyle(
            color: context.color.secondaryContrastColor,
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    FocusScope.of(context).unfocus();
                    context.toPage(TacPpView(
                        title: LocalKeys.termsAndConditions,
                        url: AppUrls.termsAndConditions));
                  },
                text: LocalKeys.termsAndConditions,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                )),
            TextSpan(
                text: ' ${LocalKeys.and} ',
                style: TextStyle(color: context.color.secondaryContrastColor)),
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    context.toPage(TacPpView(
                        title: LocalKeys.privacyPolicy,
                        url: AppUrls.privacyPolicy));
                    FocusScope.of(context).unfocus();
                  },
                text: LocalKeys.privacyPolicy,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                )),
          ]),
    );
  }
}
