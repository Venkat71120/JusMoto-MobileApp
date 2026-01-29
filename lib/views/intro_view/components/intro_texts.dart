import 'package:car_service/customizations/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/helper/extension/context_extension.dart';
import '../../../services/intro_service.dart';
import '../../../utils/components/empty_spacer_helper.dart';
import '../../../view_models/intro_view_model/intro_view_model.dart';

class IntroTexts extends StatelessWidget {
  const IntroTexts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iProvider = Provider.of<IntroService>(context, listen: false);
    final im = IntroViewModel.instance;
    return SizedBox(
      height: 200,
      child: PageView(
          controller: im.textController,
          onPageChanged: (index) {
            iProvider.setIndex(index);
            im.imageController.animateToPage(index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeIn);
          },
          children: iProvider.introData
              .map(
                (e) => Container(
                  alignment: Alignment.bottomCenter,
                  margin: context.paddingLowHorizontal,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: context.paddingLowHorizontal,
                        child: Text(
                          e['title'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                color: primaryColor,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      EmptySpaceHelper.emptyHeight(5),
                      Padding(
                        padding: context.paddingLowHorizontal,
                        child: Text(
                          e['description'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: primaryColor, fontSize: 15),
                        ),
                      ),
                      EmptySpaceHelper.emptyHeight(16),
                    ],
                  ),
                ),
              )
              .toList()),
    );
  }
}
