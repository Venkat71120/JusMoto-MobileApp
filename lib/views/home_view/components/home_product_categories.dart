import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/views/category_view/components/category_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/home_services/home_product_category_service.dart';
import '../../service_by_category_view/service_by_category_view.dart';
import 'category_card_skeleton.dart';

class HomeProductCategories extends StatelessWidget {
  const HomeProductCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProductCategoryService>(
      builder: (context, hc, child) {
        return FutureBuilder(
          future: hc.categoryList == null ? hc.fetchCategories() : null,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Container(
                margin: EdgeInsets.only(top: 16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Wrap(
                    spacing: 12,
                    children:
                        [1, 3, 6, 7, 9, 5].map((cat) {
                          return const CategoryCardSkeleton();
                        }).toList(),
                  ),
                ),
              );
            }
            if ((hc.categoryList ?? []).isEmpty) {
              return const SizedBox();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.toHeight,
                FieldLabel(label: LocalKeys.productCategories).hp20,
                12.toHeight,
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 12,
                    children:
                        hc.categoryList!.map((cat) {
                          return GestureDetector(
                            onTap: () {
                              context.toPage(
                                ServiceByCategoryView(catId: cat.id),
                              );
                            },
                            child: CategoryCard(category: cat),
                          );
                        }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
