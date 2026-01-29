import 'package:car_service/models/category_model.dart';
import 'package:car_service/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryViewModel {
  ScrollController scrollController = ScrollController();
  final TextEditingController nameController = TextEditingController();

  final ValueNotifier<Category?> selectedCategory = ValueNotifier(null);

  CategoryViewModel._init();
  static CategoryViewModel? _instance;
  static CategoryViewModel get instance {
    _instance ??= CategoryViewModel._init();
    return _instance!;
  }

  CategoryViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  tryToLoadMore(BuildContext context) {
    try {
      final ct = Provider.of<CategoryService>(context, listen: false);
      final nextPage = ct.nextPage;
      final nextPageLoading = ct.nextPageLoading;

      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (nextPage != null && !nextPageLoading) {
          ct.fetchNextPage();
          return;
        }
      }
    } catch (e) {}
  }
}
