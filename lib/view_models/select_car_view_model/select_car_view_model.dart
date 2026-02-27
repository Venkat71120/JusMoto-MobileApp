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

import '../../services/car_services/user_cars_service.dart';
import '../../views/splash_view/splash_view.dart';

class SelectCarViewModel {
  final ValueNotifier<BrandModel?> selectedBrand = ValueNotifier(null);
  final ValueNotifier<CarModel?> selectedCar = ValueNotifier(null);
  final ValueNotifier<ModelVariant?> selectedVariant = ValueNotifier(null);
  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ScrollController scrollController = ScrollController();
  final PageController pageController = PageController(initialPage: 0);
  final ValueNotifier<List<ModelVariant>> variantsList = ValueNotifier([]);
  final TextEditingController regNoController = TextEditingController();

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
        
        // At this step we will fetch the variants and they will be displayed on the next page
        
        await pageController.nextPage(
          duration: 300.milliseconds,
          curve: Curves.easeIn,
        );
        pageIndex.value = pageController.page?.toInt() ?? 0;
      default:
        // Variant Page (Index 2)
        if (selectedVariant.value == null) {
           "Please select variant type".showToast();
           return;
        }

        // Save to backend garage
        bool success = await Provider.of<UserCarsService>(context, listen: false).addUserCar(
          brandId: selectedBrand.value?.id,
          carId: selectedCar.value?.id,
          variantId: selectedVariant.value?.id,
          registrationNumber: regNoController.text.trim().isEmpty ? null : regNoController.text.trim(),
          isDefault: true,
        );

        if (!success) {
          "Failed to save car to your profile".showToast();
        }
        
        final tempCar = CarModel.fromJson(selectedCar.value?.toJson() ?? {});
        LandingViewModel.instance.selectedCar.value = tempCar;
        sPref?.setString("car", jsonEncode(tempCar.toJson()));
        sPref?.setString(
          "vId",
          selectedVariant.value?.id?.toString() ?? "",
        );
        sPref?.setString("selectedVariant", jsonEncode(selectedVariant.value?.toJson() ?? {}));
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
