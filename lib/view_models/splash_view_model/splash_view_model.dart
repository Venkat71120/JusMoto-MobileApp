// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:car_service/services/dynamics/cancellation_policy_service.dart';
import 'package:car_service/services/home_services/home_category_service.dart';
import 'package:car_service/services/home_services/home_featured_services_service.dart';
import 'package:car_service/services/home_services/home_popular_services_service.dart';
import 'package:car_service/services/home_services/home_slider_service.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/services/service/favorite_services_service.dart';
import 'package:car_service/view_models/landding_view_model/landding_view_model.dart';
import 'package:car_service/views/landing_view/landing_view.dart';
import 'package:car_service/views/select_car_view/select_car_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/helper/constant_helper.dart';
import '/helper/extension/context_extension.dart';
import '/helper/extension/string_extension.dart';
import '/helper/local_keys.g.dart';
import '/services/intro_service.dart';
import '../../helper/db_helper.dart';
import '../../helper/network_connectivity.dart';
import '../../helper/notification_helper.dart';
import '../../services/app_string_service.dart';
import '../../services/chat_services/chat_credential_service.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../../services/push_notification_service.dart';
import '../../views/intro_view/intro_view.dart';

class SplashViewModel {
  dbInit(BuildContext context) {
    List databases = ['favorite', "cart"];
    databases.map((e) => DbHelper.database(e));
    Provider.of<FavoriteServicesService>(
      context,
      listen: false,
    ).fetchFavorites();
    Provider.of<CartService>(context, listen: false).fetchCarts();
  }

  initiateStartingSequence(BuildContext context) async {
    await coreInit(context);
    dbInit(context);
    final NetworkConnectivity networkConnectivity =
        NetworkConnectivity.instance;
    final hasConnection = await networkConnectivity.currentStatus();
    if (!hasConnection) {
      dProvider.setNoConnection(true);
      LocalKeys.noConnectionFound.showToast();
      return;
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    await Future.delayed(Duration(seconds: 2));
    await Provider.of<AppStringService>(
      context,
      listen: false,
    ).defaultTranslate(context);
    final gotoIntro =
        await Provider.of<IntroService>(context, listen: false).checkIntro();
    debugPrint("intro is $gotoIntro".toString());
    if (gotoIntro) {
      CancellationPolicyService.instance.fetchCancellationPolicy();
      context.toUntilPage(const IntroView());
    } else {
      initLocalData(context);
      await Provider.of<ProfileInfoService>(
        context,
        listen: false,
      ).fetchProfileInfo(trySkip: true).then((value) async {});

      final lm = LandingViewModel.instance;
      lm.initCar();
      if (lm.selectedCar.value == null) {
        context.toPage(
          SelectCarView(),
          then: (_) {
            context.toUntilPage(const LandingView());
          },
        );
      } else {
        context.toUntilPage(const LandingView());
      }
    }
    try {
      await NotificationHelper().notificationsSetup();
      await NotificationHelper().initiateNotification(context);
      NotificationHelper().streamListener(context);
      NotificationHelper().notificationAppLaunchChecker(context);
    } catch (e) {
      debugPrint(e.toString());
      log(e.toString());
    }
  }

  initLocalData(BuildContext context) {
    PushNotificationService().updateDeviceToken();
    CancellationPolicyService.instance.fetchCancellationPolicy();
    Provider.of<HomeFeaturedServicesService>(
      context,
      listen: false,
    ).initLocal();
    Provider.of<HomePopularServicesService>(context, listen: false).initLocal();
    Provider.of<HomeSliderService>(context, listen: false).initLocal();
    Provider.of<HomeCategoryService>(context, listen: false).initLocal();
    Provider.of<ChatCredentialService>(context, listen: false).initLocal();
  }
}
