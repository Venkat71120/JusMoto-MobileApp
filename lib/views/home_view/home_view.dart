// ignore_for_file: use_build_context_synchronously

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/services/home_services/home_category_service.dart';
import 'package:car_service/services/home_services/home_popular_services_service.dart';
import 'package:car_service/services/home_services/home_slider_service.dart';
import 'package:car_service/services/home_services/unread_count_service.dart';
import 'package:car_service/services/theme_service.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/view_models/home_view_model/home_view_model.dart';
import 'package:car_service/views/home_view/components/HomeRecentOrders.dart' show HomeRecentOrders;
import 'package:car_service/views/home_view/components/home_popular_products.dart';
import 'package:car_service/views/home_view/components/home_popular_services.dart';
import 'package:car_service/views/home_view/components/home_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/home_services/home_featured_services_service.dart';
import '../../services/home_services/home_popular_products_service.dart';
import '../../services/home_services/home_product_category_service.dart';
import '../../services/home_services/landing_offer_service.dart';
import 'components/home_app_bar.dart';
import 'components/home_categories.dart';
import 'components/home_featured_services.dart';
import 'components/home_product_categories.dart';
import 'components/home_view_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final hm = HomeViewModel.instance;
    UnreadCountService.instance.fetchUnreadCounts();
    // LandingOfferService.instance.fetchPrimaryOfferContent(context);
    return CustomRefreshIndicator(
      onRefresh: () async {
        Provider.of<HomeSliderService>(
          context,
          listen: false,
        ).fetchHomeSlider();
        Provider.of<HomeFeaturedServicesService>(
          context,
          listen: false,
        ).fetchHomeFeaturedServices();
        Provider.of<HomePopularServicesService>(
          context,
          listen: false,
        ).fetchHomePopularServices();
        Provider.of<HomePopularProductsService>(
          context,
          listen: false,
        ).fetchHomePopularProducts();
        Provider.of<HomeSliderService>(
          context,
          listen: false,
        ).fetchHomeSlider();
        UnreadCountService.instance.fetchUnreadCounts();
        await Provider.of<HomeCategoryService>(
          context,
          listen: false,
        ).fetchCategories();
        await Provider.of<HomeProductCategoryService>(
          context,
          listen: false,
        ).fetchCategories();
      },
      child: Column(
        children: [
          Consumer<ThemeService>(
            builder: (context, ts, child) {
              return Expanded(
                child: Container(
                  height: context.height,
                  color: ts.selectedTheme.backgroundColor,
                  child: CustomScrollView(
                    controller: hm.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 244,
                        pinned: true,
                        leadingWidth: 0,
                        title: HomeAppBar(),
                        backgroundColor: ts.selectedTheme.backgroundColor,
                        flexibleSpace: FlexibleSpaceBar(
                          background: HomeViewHeader(),
                        ),
                      ),
                      
                      SliverList(
                        delegate: SliverChildListDelegate([
                          const HomeCategories(),
                          const HomeRecentOrders(),
                           const HomeSlider(),
                          const HomeFeaturedServices(),
                         
                          HomePopularServices(),
                          // ConstrainedBox(
                          //   constraints: BoxConstraints(
                          //     maxHeight: context.height * .4,
                          //   ),
                          //   child: HomePresentationVideo(),
                          // ),
                          const HomeProductCategories(),
                          HomePopularProducts(),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
