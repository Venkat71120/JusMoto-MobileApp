import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/Admin_landing_view_model/AdminLandingViewModel.dart';
import 'package:car_service/views/Admin_home_view/AdminHomeView.dart';
import 'package:car_service/views/Admin_landing_nav_view/components/AdminLandingNavBar.dart';
import 'package:car_service/views/Admin_orders_view/AdminOrdersView.dart';
import 'package:car_service/views/Admin_profile_view/AdminProfileView.dart';
import 'package:car_service/views/Admin_tickets_view/AdminTicketsView.dart';
import 'package:car_service/views/Admin_users_view/AdminUsersView.dart';
import 'package:flutter/material.dart';

class AdminLandingView extends StatelessWidget {
  const AdminLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final avm = AdminLandingViewModel.instance;

    final widgets = [
      const AdminHomeView(),     // index 0 — Home / Dashboard
      AdminOrdersView(),         // index 1 — Orders
      AdminTicketsView(),        // index 2 — Support Tickets
      AdminUsersView(),          // index 3 — Users Management
      const AdminProfileView(),  // index 4 — Profile
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        return Future.value(avm.willPopFunction(context));
      },
      child: Scaffold(
        key: avm.scaffoldKey,
        backgroundColor: context.color.backgroundColor,
        body: ValueListenableBuilder(
          valueListenable: avm.currentIndex,
          builder: (context, value, child) => widgets[value],
        ),
        bottomNavigationBar: const AdminLandingNavBar(),
      ),
    );
  }
}
