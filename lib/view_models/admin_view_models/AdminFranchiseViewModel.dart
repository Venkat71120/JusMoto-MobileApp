import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminFranchiseService.dart';
import '../../models/admin_models/admin_franchise_model.dart';

class AdminFranchiseViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminFranchiseViewModel(this.context);

  final TextEditingController searchController = TextEditingController();
  Timer? _searchTimer;

  void init() {
    fetchFranchises();
  }

  void fetchFranchises({int page = 1}) {
    final service = Provider.of<AdminFranchiseService>(context, listen: false);
    service.fetchFranchises(
      page: page,
      search: searchController.text,
    );
  }

  void onSearchChanged(String value) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchFranchises();
    });
  }

  Future<void> toggleFranchiseStatus(AdminFranchiseItem franchise) async {
    final service = Provider.of<AdminFranchiseService>(context, listen: false);
    final newStatus = franchise.status == 1 ? 0 : 1;
    final success = await service.updateFranchise(franchise.id, {'status': newStatus});
    if (success) {
      // Background fetch to ensure everything is in sync after local update
      fetchFranchises(page: service.franchiseList.pagination.currentPage);
    }
  }

  Future<void> deleteFranchise(int id) async {
    final service = Provider.of<AdminFranchiseService>(context, listen: false);
    final success = await service.deleteFranchise(id);
    if (success) {
      fetchFranchises(page: service.franchiseList.pagination.currentPage);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }
}
