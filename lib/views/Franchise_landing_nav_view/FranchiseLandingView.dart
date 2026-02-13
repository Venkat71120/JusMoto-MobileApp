import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/Franchise_landing_view_model/FranchiseLandingViewModel.dart';
import 'package:car_service/views/Franchise_home_view/FranchiseHomeView.dart';
import 'package:car_service/views/Franchise_landing_nav_view/components/FranchiseLandingNavBar.dart';
import 'package:car_service/views/Franchise_profile_view/FranchiseProfileView.dart';
import 'package:car_service/views/Franchise_reports_view/FranchiseReportsView.dart';
import 'package:car_service/views/franchise_orders_view/franchise_oders_view.dart';
// import 'package:car_service/views/Franchise_dashboard/franchise_home_view.dart';
// import 'package:car_service/views/Franchise_dashboard/franchise_orders_view.dart';
// import 'package:car_service/views/Franchise_dashboard/franchise_profile_view.dart';
// import 'package:car_service/views/Franchise_dashboard/franchise_reports_view.dart';
import 'package:flutter/material.dart';

// import '../../view_models/franchise_landing_view_model/franchise_landing_view_model.dart';
// import 'components/franchise_landing_nav_bar.dart';


class FranchiseLandingView extends StatelessWidget {
  const FranchiseLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final fvm = FranchiseLandingViewModel.instance;

    final widgets = [
      const FranchiseHomeView(),      // index 0 — Home / Dashboard
      const FranchiseOrdersView(),    // index 1 — Orders
      const FranchiseReportsView(),   // index 2 — Reports
      const FranchiseProfileView(),   // index 3 — Profile
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        return Future.value(fvm.willPopFunction(context));
      },
      child: Scaffold(
        key: fvm.scaffoldKey,
        backgroundColor: context.color.backgroundColor,
        body: ValueListenableBuilder(
          valueListenable: fvm.currentIndex,
          builder: (context, value, child) => widgets[value],
        ),
        bottomNavigationBar: const FranchiseLandingNavBar(),
      ),
    );
  }
}