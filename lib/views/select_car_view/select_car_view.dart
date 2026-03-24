import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/select_car_view_model/select_car_view_model.dart';
import 'package:car_service/views/select_car_view/components/select_car_brand_page.dart';
import 'package:car_service/views/select_car_view/components/select_car_model_page.dart';
import 'package:flutter/material.dart';

import 'components/select_car_details_page.dart';

class SelectCarView extends StatelessWidget {
  const SelectCarView({super.key});

  @override
  Widget build(BuildContext context) {
    final scm = SelectCarViewModel.instance;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          SelectCarViewModel.dispose;
          return;
        }
        scm.goBack(context);
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.color.backgroundColor,
          leading: NavigationPopIcon(
            onTap: () {
              scm.goBack(context);
            },
          ),
          title: Text(scm.isEditing ? "Update Your Car" : LocalKeys.selectYourCar),
        ),
        body: PageView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            controller: PageController(initialPage: scm.isEditing ? 2 : 0),
            itemBuilder: (context, index) {
              return [
                SelectCarBrandPage(),
                SelectCarModelPage(),
                SelectCarDetailsPage(),
              ][index];
            }),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: ValueListenableBuilder(
              valueListenable: scm.pageIndex,
              builder: (context, value, child) {
                return Row(
                  children: [
                    if (value > 0 && !(scm.isEditing && value == 2)) ...[
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            scm.goBack(context);
                          },
                          child: Text(LocalKeys.back),
                        ),
                      ),
                      8.toWidth,
                    ],
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          scm.continueForward(context);
                        },
                        child: Text(LocalKeys.continueO),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
