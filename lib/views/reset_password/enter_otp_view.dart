import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '/helper/extension/context_extension.dart';
import '/helper/local_keys.g.dart';
import '/utils/components/field_label.dart';
import '../../customizations/colors.dart';
import '../../services/auth_services/email_otp_service.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/empty_spacer_helper.dart';
import '../../utils/components/navigation_pop_icon.dart';

class EnterOtpView extends StatelessWidget {
  static const routeName = 'enter_otp_view';
  String? otp;
  bool fromRegister;
  final token;
  final email;
  EnterOtpView(this.otp,
      {this.fromRegister = false, this.token, this.email, super.key});
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
                LottieBuilder.asset(
                  "assets/animations/otp_animation.json",
                  repeat: false,
                ),
                Form(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      FieldLabel(label: LocalKeys.enterYourVerificationCode),
                      Text(
                        LocalKeys.doNotShareCode,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                                      color:
                                          context.color.secondaryContrastColor),
                                ),
                              ),
                              EmptySpaceHelper.emptyWidth(5),
                              Consumer<EmailManageService>(
                                builder: (context, em, child) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      child!,
                                      if (em.loadingSendOTP)
                                        Container(
                                          color:
                                              context.color.accentContrastColor,
                                          height: 40,
                                          width: 80,
                                          child: const FittedBox(
                                              child: CustomPreloader()),
                                        ),
                                      if (!em.canSend)
                                        Container(
                                          color:
                                              context.color.accentContrastColor,
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
                                                          color: primaryColor)),
                                              4.toWidth,
                                              FittedBox(
                                                child: SlideCountdownSeparated(
                                                  showZeroValue: true,
                                                  shouldShowMinutes: (p0) =>
                                                      true,
                                                  shouldShowDays: (p0) => false,
                                                  shouldShowHours: (p0) =>
                                                      false,
                                                  padding: EdgeInsets.zero,
                                                  separatorPadding:
                                                      EdgeInsets.zero,
                                                  style: context
                                                      .titleSmall!.bold6
                                                      .copyWith(
                                                          color: context.color
                                                              .primaryWarningColor),
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
                                                      seconds: 120),
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
                                          Provider.of<EmailManageService>(
                                                  context,
                                                  listen: false)
                                              .tryOtpToEmail(
                                                  emailUsername: email);
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
    );
  }

  Pinput otpPinput(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 70,
      height: 56,
      textStyle: context.titleSmall,
      decoration: BoxDecoration(
        border: Border.all(color: context.color.primaryBorderColor),
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
      length: otp?.length ?? 6,
      validator: (s) {
        if (s != Provider.of<EmailManageService>(context, listen: false).otp) {
          controller!.clear();
          context.snackBar(LocalKeys.wrongOTPCode,
              backgroundColor: context.color.primaryWarningColor,
              buttonText: LocalKeys.resendCode, onTap: () {
            controller!.clear();
            Provider.of<EmailManageService>(context, listen: false)
                .tryOtpToEmail(emailUsername: email);
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
          });
          return;
        }
        context.popTrue;
        return;
      },
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: (pin) => print(pin),
    );
  }
}
