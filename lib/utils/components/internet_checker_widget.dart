import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../services/internet_checker_service.dart';
import 'empty_spacer_helper.dart';

class InternetCheckerWidget extends StatelessWidget {
  final Widget widget;
  final Widget loadingWidget;
  final retryFunction;

  const InternetCheckerWidget(
      {required this.widget,
      required this.loadingWidget,
      this.retryFunction,
      super.key});

  @override
  Widget build(BuildContext context) {
    final ic = Provider.of<InternetCheckerService>(context, listen: false);
    return FutureBuilder(
      future: ic.checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget;
        }
        return ic.haveConnection
            ? widget
            : Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: context.height / 1.5,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LottieBuilder.asset(
                                  'assets/animations/no_internet.json',
                                  height: context.height / 2,
                                ),
                              ],
                            ),
                          ]),
                    ),
                    EmptySpaceHelper.emptyHeight(16),
                    Text(
                      LocalKeys.oops,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    EmptySpaceHelper.emptyHeight(8),
                    Text(
                      LocalKeys.noConnectionFound,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    EmptySpaceHelper.emptyHeight(24),
                    if (retryFunction != null)
                      CustomButton(
                          onPressed: () async {
                            ic.setHaveConnection(true);
                            retryFunction();
                          },
                          btText: LocalKeys.retry,
                          width: 100,
                          isLoading: false)
                  ],
                ),
              );
      },
    );
  }
}
