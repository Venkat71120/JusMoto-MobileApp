import 'package:car_service/views/intro_view/components/intro_images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/intro_service.dart';
import 'components/intro_base.dart';

class IntroView extends StatelessWidget {
  static const routeName = "intro_view";
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IntroService>(builder: (context, iProvider, child) {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              IntroImages(),
              const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IntroBase(),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
