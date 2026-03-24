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
import '../../services/car_services/variant_list_service.dart';
import '../../views/splash_view/splash_view.dart';

class SelectCarViewModel {
  final ValueNotifier<BrandModel?> selectedBrand = ValueNotifier(null);
  final ValueNotifier<CarModel?> selectedCar = ValueNotifier(null);
  final ValueNotifier<ModelVariant?> selectedVariant = ValueNotifier(null);
  ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ScrollController scrollController = ScrollController();
  PageController pageController = PageController(initialPage: 0);
  final ValueNotifier<List<ModelVariant>> variantsList = ValueNotifier([]);
  final TextEditingController regNoController = TextEditingController();
  
  dynamic editingCarId;
  bool get isEditing => editingCarId != null;

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
        break;
      default:
        // Variant Page (Index 2)
        final variants = Provider.of<VariantListService>(context, listen: false)
            .variantListModel
            .allVariants ?? [];
        if (variants.isNotEmpty && selectedVariant.value == null) {
           "Please select variant type".showToast();
           return;
        }

        // Save to backend garage
        bool success;
        if (isEditing) {
          success = await Provider.of<UserCarsService>(context, listen: false).updateUserCar(
            id: editingCarId,
            brandId: selectedBrand.value?.id,
            carId: selectedCar.value?.id,
            variantId: selectedVariant.value?.id,
            registrationNumber: regNoController.text.trim().isEmpty ? null : regNoController.text.trim(),
            isDefault: true,
          );
        } else {
          success = await Provider.of<UserCarsService>(context, listen: false).addUserCar(
            brandId: selectedBrand.value?.id,
            carId: selectedCar.value?.id,
            variantId: selectedVariant.value?.id,
            registrationNumber: regNoController.text.trim().isEmpty ? null : regNoController.text.trim(),
            isDefault: true,
          );
        }

        if (!success) {
          if (isEditing) {
            "Failed to update car details".showToast();
          } else {
            "Failed to save car to your profile".showToast();
          }
          return;
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
        context.pop;
    }
  }

  goBack(BuildContext context, {bool forceSteps = false}) async {
    if (pageIndex.value <= 0 || (isEditing && pageIndex.value == 2 && !forceSteps)) {
      context.pop;
      return;
    }
    await pageController.previousPage(
      duration: 300.milliseconds,
      curve: Curves.easeIn,
    );
    pageIndex.value = pageController.page?.toInt() ?? 0;
  }

  void setEditingCar(UserSelectedCarModel car) {
    editingCarId = car.id;
    regNoController.text = car.registrationNumber ?? "";
    
    // Jump straight to the details page (index 2) so the user doesn't have to navigate from Brand again
    pageIndex.value = 2;
    pageController = PageController(initialPage: 2);
    
    // Note: We can only set IDs here. 
    // The lists for models and variants are normally fetched when brand/car are selected.
    // For a better UX, one might want to pre-fetch these, 
    // but typically the user will select brand -> model -> variant anyway.
    // We'll at least set the initial selections if we had the full models, 
    // but UserSelectedCarModel only has names and IDs.
    
    selectedBrand.value = BrandModel(id: car.brandId, name: car.brandName);
    selectedCar.value = CarModel(id: car.carId, name: car.carName, image: car.carImage);
    selectedVariant.value = ModelVariant(id: car.variantId);
  }
}
