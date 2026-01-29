import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/image_assets.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/view_models/filter_view_model/filter_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/service/services_search_service.dart';
import '../../../view_models/home_view_model/home_view_model.dart';
import '../../../view_models/landding_view_model/landding_view_model.dart';
import 'home_header_painter.dart';

class HomeViewHeader extends StatelessWidget {
  const HomeViewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final fvm = FilterViewModel.instance;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 28),
          width: context.width,
          decoration: BoxDecoration(
            color: primaryColor,
            image: DecorationImage(
              image: ImageAssets.logoPattern.toAsset,
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Stack(
            children: [
              Transform.flip(
                flipX: dProvider.textDirectionRight,
                child: CustomPaint(
                  size: Size(
                    (context.width * .8),
                    (context.width * 0.8).toDouble(),
                  ), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                  painter: HomeHeaderPainter(
                    color: primaryColor,
                    sizes: Size(
                      (context.width * .8),
                      (context.width * 0.8).toDouble(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: SizedBox(
            width: context.width,
            child: HomeSearchField(fvm: fvm),
          ),
        ),
        Positioned(
          right: dProvider.textDirectionRight ? null : 0,
          left: dProvider.textDirectionRight ? 0 : null,
          bottom: 32,
          child: Transform.flip(
            flipX: dProvider.textDirectionRight,
            child: ImageAssets.headerCar.toAImage(),
          ),
        ),
      ],
    );
  }
}

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key, required this.fvm});

  final FilterViewModel fvm;

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
      margin: EdgeInsets.symmetric(horizontal: 20),
      color: context.color.accentContrastColor,
      radius: 22,
      child: TextFormField(
        controller: fvm.searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: LocalKeys.search,
          fillColor: context.color.accentContrastColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: context.color.primaryBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: context.color.primaryBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: context.color.primaryBorderColor),
          ),
          prefixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                child: Row(
                  children: [
                    4.toWidth,
                    SvgAssets.search.toSVGSized(
                      24,
                      color: context.color.secondaryContrastColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onFieldSubmitted: (value) {
          Provider.of<ServicesSearchService>(
            context,
            listen: false,
          ).resetFilters();
          Provider.of<ServicesSearchService>(
            context,
            listen: false,
          ).setSearchTitle(fvm.searchController.text);
          HomeViewModel.instance.appBarSize.value = 0;
          final ov = LandingViewModel.instance;
          ov.setNavIndex(2);
        },
        onTapOutside: (event) {
          context.unFocus;
        },
      ),
    );
  }
}
