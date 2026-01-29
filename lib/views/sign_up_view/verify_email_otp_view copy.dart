import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '/helper/extension/context_extension.dart';
import '/helper/local_keys.g.dart';
import '/utils/components/field_label.dart';
import '../../customizations/colors.dart';
import '../../services/otp_service.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/empty_spacer_helper.dart';
import '../../utils/components/navigation_pop_icon.dart';
import './../../helper/extension/int_extension.dart';
import './../../helper/extension/string_extension.dart';
import './../../helper/image_assets.dart';
import 'sign_up_name_date.dart';

class VerifyEmailOtpView extends StatelessWidget {
  static const routeName = 'enter_otp_view';
  final String otp;
  final email;
  VerifyEmailOtpView(this.otp, {this.email, super.key});
  TextEditingController? controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OtpService>(
      create: (context) => OtpService(),
      child: PopScope(
        onPopInvoked: (_) {},
        child: Scaffold(
          backgroundColor: context.color.accentContrastColor,
          appBar: AppBar(
            leading: NavigationPopIcon(
              onTap: () {
                context.popFalse;
              },
            ),
            title: Text(LocalKeys.verificationCode.capitalizeWords),
          ),
          body: SingleChildScrollView(
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
                        FieldLabel(label: LocalKeys.enterYourVerificationCode),
                        Text(
                          LocalKeys.doNotShareCode,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: context.color.secondaryContrastColor),
                        ),
                        EmptySpaceHelper.emptyHeight(20),
                        Center(child: otpPinput(context)),
                        EmptySpaceHelper.emptyHeight(30),
                        SizedBox(
                          height: 40,
                          child: Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                RichText(
                                  softWrap: true,
                                  text: TextSpan(
                                    text: LocalKeys.didNotReceived,
                                    style: context.titleSmall?.bold.copyWith(
                                        color: context
                                            .color.secondaryContrastColor),
                                  ),
                                ),
                                EmptySpaceHelper.emptyWidth(5),
                                Consumer<OtpService>(
                                  builder: (context, otpProvider, child) {
                                    return Stack(
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
                                        if (otpProvider.sendAgainOptionTimer !=
                                                null &&
                                            !otpProvider.loadingSendOTP)
                                          Container(
                                            color: context
                                                .color.accentContrastColor,
                                            constraints: const BoxConstraints(
                                                maxHeight: 40),
                                            child: Wrap(
                                              alignment: WrapAlignment.center,
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
                                                    shouldShowMinutes: (p0) =>
                                                        true,
                                                    shouldShowDays: (p0) =>
                                                        false,
                                                    shouldShowHours: (p0) =>
                                                        false,
                                                    padding: EdgeInsets.zero,
                                                    separatorPadding:
                                                        EdgeInsets.zero,
                                                    style: context
                                                        .titleSmall!.bold6
                                                        .copyWith(
                                                            color: context.color
                                                                .mutedWarningColor),
                                                    separator: ':',
                                                    separatorStyle: context
                                                        .titleSmall!.bold6
                                                        .copyWith(
                                                            color: context.color
                                                                .primaryWarningColor),
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    duration: const Duration(
                                                        seconds: 30),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                      ],
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            controller!.clear();
                                            Provider.of<OtpService>(context,
                                                    listen: false)
                                                .sendOTPWithoutToken(
                                                    context, email);
                                          },
                                        text: LocalKeys.sendAgain,
                                        style: const TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold)),
                                  ),
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
        ),
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
      length: otp.length,
      validator: (s) {
        if (s != otp &&
            s != Provider.of<OtpService>(context, listen: false).otpCode) {
          controller!.clear();
          context.snackBar(LocalKeys.wrongOTPCode,
              backgroundColor: context.color.primaryWarningColor,
              buttonText: LocalKeys.resendCode, onTap: () {
            controller!.clear();
            Provider.of<OtpService>(context, listen: false)
                .sendOTPWithoutToken(context, email);

            ScaffoldMessenger.of(context).removeCurrentSnackBar();
          });
          return;
        }
        context.toPage(const SignUpNameDate());

        return;
      },
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: (pin) => print(pin),
    );
  }
}
