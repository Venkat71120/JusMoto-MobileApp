import 'package:car_service/customizations/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/helper/extension/context_extension.dart';
import '/services/dynamics/dynamics_service.dart';
import '../../helper/local_keys.g.dart';
import '../../view_models/splash_view_model/splash_view_model.dart';
import 'components/splash_video.dart';

class SplashView extends StatelessWidget {
  static const routeName = '/';
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    SplashViewModel().initiateStartingSequence(context);
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ButterFlyAssetVideo(),
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/splash.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Commented out the retry button/popup for now
              // Consumer<DynamicsService>(builder: (context, lProvider, child) {
              //   return Positioned(
              //     bottom: context.width / 2.5,
              //     child: lProvider.noConnection
              //         ? TextButton(
              //             onPressed: () {
              //               lProvider.setNoConnection(false);
              //               SplashViewModel().initiateStartingSequence(context);
              //             },
              //             style: TextButton.styleFrom(
              //               foregroundColor: primaryColor,
              //               backgroundColor: context.color.accentContrastColor,
              //               padding: const EdgeInsets.symmetric(horizontal: 40),
              //               shape: RoundedRectangleBorder(
              //                   borderRadius: BorderRadius.circular(12)),
              //               surfaceTintColor: Colors.transparent,
              //               splashFactory: NoSplash.splashFactory,
              //               elevation: 0,
              //             ),
              //             child: Text(
              //               LocalKeys.retry,
              //               style: Theme.of(context)
              //                   .textTheme
              //                   .titleSmall!
              //                   .copyWith(color: primaryColor),
              //             ),
              //           )
              //         : SizedBox(),
              //   );
              // }),
            ],
          ),
        ),
      ),
    );
  }
}