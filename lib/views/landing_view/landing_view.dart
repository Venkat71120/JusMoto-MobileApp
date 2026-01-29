import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/landding_view_model/landding_view_model.dart';
import 'package:car_service/views/landing_view/components/landing_bottom_nav.dart';
import 'package:flutter/material.dart';

import '../../services/payment/paytr_api_payment.dart';
import '../home_view/home_view.dart';
import '../menu_view/menu_view.dart';
import '../my_car_view/my_car_view.dart';
import '../order_list_view/order_list_view.dart';
import '../products_list_view/products_list_view.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final lvm = LandingViewModel.instance;

    final widgets = [
      const HomeView(),
      const OrderListView(),
      const ProductsListView(),
      const MyCarView(),
      const MenuView(),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        return Future.value(lvm.willPopFunction(context));
      },
      child: Scaffold(
        key: lvm.scaffoldKey,
        backgroundColor: context.color.backgroundColor,
        body: ValueListenableBuilder(
          valueListenable: lvm.currentIndex,
          builder: (context, value, child) => widgets[value],
        ),
        bottomNavigationBar: const LandingNavBar(),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: context.color.accentContrastColor,
        //   onPressed: () {
        //     debugPrint(context.width.toString());

        //     return;
        //     context.toPage(
        //       PaytrApiPayment(
        //         onSuccess: () {
        //           context.pop();
        //           print("Success");
        //         },
        //         onFailed: () {
        //           context.pop();
        //           print("Failed");
        //         },
        //         amount: 100,
        //         merchantId: "276512",
        //         merchantKey: "3AqsFNNcZTsKY8Zp",
        //         merchantSalt: "PhnjTCmDAW1XgunZ",
        //         productName: "Product Name",
        //         currency: "TL",
        //         userName: "User Name",
        //         userEmail: "",
        //         userPhone: "",
        //         lang: "tr",
        //         linkType: "product",
        //       ),
        //     );
        //   },
        //   child: const Icon(Icons.add),
        // ),
      ),
    );
  }
}
