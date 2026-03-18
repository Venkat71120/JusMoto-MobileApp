import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '/helper/extension/context_extension.dart';
import '/helper/local_keys.g.dart';
import '/utils/components/field_label.dart';
import '../../customizations/colors.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/empty_spacer_helper.dart';
import '../../utils/components/navigation_pop_icon.dart';
import './../../helper/image_assets.dart';
import '../../services/auth_services/email_otp_service.dart';

class ChangeEmailOtpView extends StatelessWidget {
  static const routeName = 'enter_otp_view';
  ChangeEmailOtpView({super.key});
  TextEditingController? controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {},
      child: Scaffold(
        appBar: AppBar(
          leading: NavigationPopIcon(
            onTap: () {
              context.popFalse;
            },
          ),
          title: Text(LocalKeys.verificationCode.capitalizeWords),
        ),
        body: Consumer<EmailManageService>(
            builder: (context, otpProvider, child) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: context.color.accentContrastColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ImageAssets.verification.toAImage(),
                          ),
                          24.toHeight,
                          Form(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                FieldLabel(
                                    label: LocalKeys
                                        .enterYourVerificationCode),
                                Text(
                                  LocalKeys.doNotShareCode,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          color: context
                                              .color.secondaryContrastColor),
                                ),
                                EmptySpaceHelper.emptyHeight(20),
                                Center(child: otpPinput(context)),
                                EmptySpaceHelper.emptyHeight(30),
                                SizedBox(
                                  height: 40,
                                  child: Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        RichText(
                                          softWrap: true,
                                          text: TextSpan(
                                            text: LocalKeys.didNotReceived,
                                            style: context.titleSmall?.bold
                                                .copyWith(
                                                    color: context.color
                                                        .secondaryContrastColor),
                                          ),
                                        ),
                                        EmptySpaceHelper.emptyWidth(5),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            child!,
                                            if (otpProvider.loadingSendOTP)
                                              Container(
                                                color: context
                                                    .color.accentContrastColor,
                                                height: 40,
                                                width: 80,
                                                child: const FittedBox(
                                                    child: CustomPreloader()),
                                              ),
                                            if (!otpProvider.canSend &&
                                                !otpProvider.loadingSendOTP)
                                              Container(
                                                color: context
                                                    .color.accentContrastColor,
                                                constraints:
                                                    const BoxConstraints(
                                                        maxHeight: 40),
                                                child: Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    Text(LocalKeys.resend,
                                                        style: context
                                                            .titleSmall!.bold6
                                                            .copyWith(
                                                                color:
                                                                    primaryColor)),
                                                    FittedBox(
                                                      child:
                                                          SlideCountdownSeparated(
                                                        showZeroValue: true,
                                                        shouldShowMinutes:
                                                            (p0) => true,
                                                        shouldShowDays: (p0) =>
                                                            false,
                                                        shouldShowHours: (p0) =>
                                                            false,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        separatorPadding:
                                                            EdgeInsets.zero,
                                                        style: context
                                                            .titleSmall!.bold6
                                                            .copyWith(
                                                                color: context
                                                                    .color
                                                                    .primaryContrastColor),
                                                        separator: ':',
                                                        separatorStyle: context
                                                            .titleSmall!.bold6
                                                            .copyWith(
                                                                color: context
                                                                    .color
                                                                    .primaryContrastColor),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        duration:
                                                            const Duration(
                                                                seconds: 120),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ])),
                        ],
                      ),
                    ),
                  ),
                  if (otpProvider.loadingVerify)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      color: context.color.accentContrastColor.withOpacity(.7),
                      child: const CustomPreloader(),
                    )
                ],
              );
            },
            child: RichText(
              text: TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      controller!.clear();
                      Provider.of<EmailManageService>(context, listen: false)
                          .tryOtpToNewEmail();
                    },
                  text: LocalKeys.sendAgain,
                  style: const TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold)),
            )),
      ),
    );
  }

  Pinput otpPinput(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 70,
      height: 56,
      textStyle: TextStyle(
        fontSize: 17,
        color: context.color.primaryContrastColor,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: context.color.primaryContrastColor),
        borderRadius: BorderRadius.circular(8),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: primaryColor),
      borderRadius: BorderRadius.circular(8),
    );
    return Pinput(
      controller: controller,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      keyboardType: TextInputType.visiblePassword,
      length: 6,
      validator: (s) {
        if (s == null || s.isEmpty) return null;
        Provider.of<EmailManageService>(context, listen: false)
            .tryEmailChange(otp: s)
            .then((v) {
          if (v != true) return;
          context.popTrue;
        });
        return null;
      },
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: (pin) => debugPrint(pin),
    );
  }
}
