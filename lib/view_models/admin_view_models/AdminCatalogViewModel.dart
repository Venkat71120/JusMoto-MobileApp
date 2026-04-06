import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminCatalogService.dart';
import '../../models/admin_models/admin_catalog_models.dart';

class AdminCatalogViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminCatalogViewModel(this.context);

  final TextEditingController searchController = TextEditingController();
  final TextEditingController categorySearchController = TextEditingController();
  
  String statusFilter = '';
  String featuredFilter = '';
  int currentType = 0; // 0=Service, 1=Product

  Timer? _searchTimer;

  void initCategories() {
    fetchCategories();
  }

  void initServices(int type) {
    currentType = type;
    fetchServices();
  }

  void fetchCategories({int page = 1}) {
    final service = Provider.of<AdminCatalogService>(context, listen: false);
    service.fetchCategories(page: page, search: categorySearchController.text);
  }

  void fetchServices({int page = 1}) {
    final service = Provider.of<AdminCatalogService>(context, listen: false);
    service.fetchServices(
      page: page,
      search: searchController.text,
      type: currentType,
      status: statusFilter,
      isFeatured: featuredFilter,
    );
  }

  void onSearchChanged(String value) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchServices();
    });
  }

  void onCategorySearchChanged(String value) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchCategories();
    });
  }

  void onStatusFilterChanged(String? val) {
    statusFilter = val ?? '';
    fetchServices();
    notifyListeners();
  }

  void onFeaturedFilterChanged(String? val) {
    featuredFilter = val ?? '';
    fetchServices();
    notifyListeners();
  }

  Future<void> toggleStatus(AdminServiceItem item) async {
    final service = Provider.of<AdminCatalogService>(context, listen: false);
    await service.toggleServiceStatus(item.id);
  }

  Future<void> toggleFeatured(AdminServiceItem item) async {
    final service = Provider.of<AdminCatalogService>(context, listen: false);
    await service.toggleServiceFeatured(item.id);
  }

  Future<void> deleteService(int id) async {
    final service = Provider.of<AdminCatalogService>(context, listen: false);
    await service.deleteService(id);
  }

  Future<void> deleteCategory(int id) async {
    final service = Provider.of<AdminCatalogService>(context, listen: false);
    await service.deleteCategory(id);
  }

  @override
  void dispose() {
    searchController.dispose();
    categorySearchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }
}
