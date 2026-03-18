import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '/helper/extension/context_extension.dart';
import '/services/intro_service.dart';
import '../../../helper/extension/int_extension.dart';
import '../../../helper/local_keys.g.dart';
import '../../../utils/components/custom_button.dart';
import '../../../view_models/intro_view_model/intro_view_model.dart';
import '../../landing_view/landing_view.dart';
import '../../sign_in_view/sign_in_view.dart';

class IntroBase extends StatelessWidget {
  const IntroBase({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    return Consumer<IntroService>(builder: (context, iProvider, child) {
      final im = IntroViewModel.instance;
      return SafeArea(
        top: false,
        bottom: false,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        context.toPage(const SignInView(), then: (_) {
                          if (!context.mounted) return;
                          Provider.of<IntroService>(context, listen: false)
                              .seeIntroValue();
                          context.toUntilPage(const LandingView());
                        });
                      },
                      child: Text(
                        LocalKeys.skip,
                        style: TextStyle(
                          color: context.color.accentContrastColor,
                        ),
                      ),
                    ),
                  ),
                  20.toWidth,
                  Expanded(
                    flex: 1,
                    child: CustomButton(
                      isLoading: false,
                      onPressed: () {
                        if (iProvider.currentIndex ==
                            (iProvider.introData.length - 1)) {
                          context.toPage(const SignInView(), then: (_) {
                            if (!context.mounted) return;
                            Provider.of<IntroService>(context, listen: false)
                                .seeIntroValue();
                            context.toUntilPage(const LandingView());
                          });
                          return;
                        }
                        im.imageController.nextPage(
                            duration: 400.milliseconds, curve: Curves.easeIn);
                      },
                      btText: LocalKeys.continueO,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
