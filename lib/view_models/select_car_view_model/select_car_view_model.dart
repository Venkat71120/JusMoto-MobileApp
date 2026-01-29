import 'dart:convert';

import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/car_models/brand_list_model.dart';
import 'package:car_service/models/car_models/car_model_list_model.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/view_models/landding_view_model/landding_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../views/splash_view/splash_view.dart';

class SelectCarViewModel {
  final ValueNotifier<BrandModel?> selectedBrand = ValueNotifier(null);
  final ValueNotifier<CarModel?> selectedCar = ValueNotifier(null);
  final ValueNotifier<String?> selectedEngine = ValueNotifier(null);
  final ValueNotifier<String?> selectedFuel = ValueNotifier(null);
  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ScrollController scrollController = ScrollController();
  final PageController pageController = PageController(initialPage: 0);

  SelectCarViewModel._init();
  static SelectCarViewModel? _instance;
  static SelectCarViewModel get instance {
    _instance ??= SelectCarViewModel._init();
    return _instance!;
  }

  static bool get dispose {
    _instance = null;
    return true;
  }

  continueForward(BuildContext context) async {
    debugPrint(pageIndex.value.toString());
    switch (pageIndex.value) {
      case 0:
        if (selectedBrand.value == null) {
          LocalKeys.selectCarBrand.showToast();
          return;
        }
        await pageController.nextPage(
          duration: 300.milliseconds,
          curve: Curves.easeIn,
        );
        pageIndex.value = pageController.page?.toInt() ?? 0;
        break;
      case 1:
        if (selectedCar.value == null) {
          LocalKeys.selectYourCarModel.showToast();
          return;
        }
        final variants = selectedCar.value?.variants ?? [];
        final uniqIds = variants.map((v) => v.engineType?.id).toSet().toList();
        final List<VariantTypes> engines = [];
        for (var element in uniqIds) {
          final vt =
              variants
                  .firstWhere((el) => el.engineType?.id == element)
                  .engineType;
          if (vt == null) continue;
          engines.add(vt);
        }
        selectedEngine.value ??= engines.firstOrNull?.id?.toString();
        await pageController.nextPage(
          duration: 300.milliseconds,
          curve: Curves.easeIn,
        );
        pageIndex.value = pageController.page?.toInt() ?? 0;
      default:
        final tempCar = CarModel.fromJson(selectedCar.value?.toJson() ?? {});
        tempCar.variants.removeWhere((element) {
          return (element.engineType?.id?.toString() != selectedEngine.value ||
              element.fuelType?.id?.toString() != selectedFuel.value);
        });
        LandingViewModel.instance.selectedCar.value = tempCar;
        sPref?.setString("car", jsonEncode(tempCar.toJson()));
        sPref?.setString(
          "vId",
          tempCar.variants.firstOrNull?.id?.toString() ?? "",
        );
        Provider.of<CartService>(context, listen: false).clearCart();
        if (sPref?.getBool("intro") ?? false) {
          context.toUntilPage(SplashView());
        } else {
          context.pop;
        }
    }
  }

  goBack(BuildContext context) async {
    if (pageIndex.value <= 0) {
      context.pop;
      return;
    }
    await pageController.previousPage(
      duration: 300.milliseconds,
      curve: Curves.easeIn,
    );
    pageIndex.value = pageController.page?.toInt() ?? 0;
  }
}
