// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:car_service/services/Franchise_dashboard_Services/franchise_dashboard_service.dart';
import 'package:car_service/services/auth_services/FranchiseLoginService.dart';
import 'package:car_service/services/dynamics/cancellation_policy_service.dart';
import 'package:car_service/services/home_services/home_category_service.dart';
import 'package:car_service/services/home_services/home_featured_services_service.dart';
import 'package:car_service/services/home_services/home_popular_services_service.dart';
import 'package:car_service/services/home_services/home_slider_service.dart';
import 'package:car_service/services/service/cart_service.dart';
import 'package:car_service/services/service/favorite_services_service.dart';
import 'package:car_service/view_models/Franchise_landing_view_model/FranchiseLandingViewModel.dart';
import 'package:car_service/view_models/landding_view_model/landding_view_model.dart';
import 'package:car_service/views/Franchise_landing_nav_view/FranchiseLandingView.dart';
import 'package:car_service/views/landing_view/landing_view.dart';
import 'package:car_service/views/select_car_view/select_car_view.dart';
import 'package:car_service/views/sign_in_view/sign_in_view.dart';
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
    // Removed fixed 2s delay as it produced a double-splash effect
    // await Future.delayed(Duration(seconds: 2));
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
      // ✅ Check if login session has expired (6 months)
      if (isSessionExpired()) {
        debugPrint("⏰ Session expired (older than $sessionDurationDays days) — logging out");
        setToken("");
        clearLoginTimestamp();
        sPref?.remove("is_franchise");
        LocalKeys.sessionExpired.showToast();
      }

      // ✅ CRITICAL: Initialize franchise data from SharedPreferences FIRST
      final flService = Provider.of<FranchiseLoginService>(context, listen: false);
      await flService.initFranchiseData();

      final isFranchise = flService.isFranchiseUser;
      final hasToken = flService.token.isNotEmpty;

      debugPrint("🔍 Checking user type - isFranchise: $isFranchise, hasToken: $hasToken");

      if (isFranchise && hasToken) {
        // ✅ FRANCHISE USER FLOW
        debugPrint("👤 Franchise user detected - navigating to FranchiseLandingView");
        
        await initFranchiseData(context);
        
        // ✅ DON'T fetch regular user profile for franchise users
        // The franchise data is already loaded in FranchiseLoginService
        
        FranchiseLandingViewModel.instance.currentIndex.value = 0;
        context.toUntilPage(const FranchiseLandingView());
        
      } else {
        // ✅ REGULAR USER FLOW
        debugPrint("👤 Regular user detected - navigating to LandingView");
        
        initLocalData(context);
        
        // ✅ Only fetch profile for regular users
        await Provider.of<ProfileInfoService>(
          context,
          listen: false,
        ).fetchProfileInfo(trySkip: true);

        if (getToken.isEmpty) {
          // Not signed in — show sign-in page
          context.toPage(
            const SignInView(),
            then: (_) {
              if (!context.mounted) return;
              context.toUntilPage(const LandingView());
            },
          );
        } else {
          // Signed in — go to home
          final lm = LandingViewModel.instance;
          lm.initCar();
          context.toUntilPage(const LandingView());
        }
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

  // ✅ Initialize franchise-specific data
  initFranchiseData(BuildContext context) {
    debugPrint("🔧 Initializing franchise data");
    PushNotificationService().updateDeviceToken();
    
    // Fetch franchise dashboard data
    Provider.of<FranchiseDashboardService>(context, listen: false).fetchDashboard();
    
    // Fetch chat credentials
    Provider.of<ChatCredentialService>(context, listen: false).initLocal();
    
    // ✅ DON'T fetch regular user profile info for franchise users
    // The franchise user info is already in FranchiseLoginService
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