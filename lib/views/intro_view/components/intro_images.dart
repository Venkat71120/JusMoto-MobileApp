import 'package:car_service/view_models/intro_view_model/intro_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/intro_service.dart';

class IntroImages extends StatelessWidget {
  const IntroImages({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iProvider = Provider.of<IntroService>(context, listen: false);
    final im = IntroViewModel.instance;
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: PageView(
          controller: im.imageController,
          onPageChanged: (index) {
            iProvider.setIndex(index);
          },
          children: iProvider.introData
              .map(
                (e) => Container(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image.asset(
                      e['image'].toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
              .toList()),
    );
  }
}
