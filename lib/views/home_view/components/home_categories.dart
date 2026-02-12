import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/views/category_view/components/category_card.dart';
import 'package:car_service/views/home_view/components/auto_scroll_category_list.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/home_services/home_category_service.dart';
import '../../service_by_category_view/service_by_category_view.dart';
import 'category_card_skeleton.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeCategoryService>(
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
                    children: [1, 3, 6, 7, 9, 5].map((cat) {
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
                FieldLabel(label: LocalKeys.categories).hp20,
                12.toHeight,
                // Replace the SingleChildScrollView with AutoScrollCategoryList
                AutoScrollCategoryList(
                  categories: hc.categoryList!,
                  onCategoryTap: (cat) {
                    context.toPage(
                      ServiceByCategoryView(catId: cat.id),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
// ```

// **Key differences from before:**

// 1. ✅ Uses `SingleChildScrollView` instead of `ListView` (matches your original structure)
// 2. ✅ Uses `Wrap` to maintain the same layout
// 3. ✅ Longer delay (800ms) to ensure categories are fully loaded
// 4. ✅ Extensive debug logging to see what's happening
// 5. ✅ Proper file location in `home_view/components/`

// **Now run the app and check the debug console.** You should see messages like:
// ```
// 🔵 AutoScrollCategoryList: initState - 6 categories
// 🟢 PostFrameCallback executed
// 🟡 Starting auto-scroll...
// 🟡 MaxScroll: 450.0
// ✅ Auto-scroll STARTED! MaxScroll: 450.0