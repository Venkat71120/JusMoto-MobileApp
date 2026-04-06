import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminVehicleService.dart';
import '../../models/admin_models/admin_vehicle_models.dart';

class AdminVehicleViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminVehicleViewModel(this.context);

  final TextEditingController brandSearchController = TextEditingController();
  final TextEditingController carSearchController = TextEditingController();
  
  int? brandFilter;
  String sortField = 'id';
  String sortOrder = 'DESC';

  Timer? _searchTimer;

  void initBrands() {
    fetchBrands();
  }

  void initCars() {
    fetchBrands(); // Needed for filtering and creation
    fetchCars();
  }

  void fetchBrands({int page = 1}) {
    final service = Provider.of<AdminVehicleService>(context, listen: false);
    service.fetchBrands(page: page, search: brandSearchController.text);
  }

  void fetchCars({int page = 1}) {
    final service = Provider.of<AdminVehicleService>(context, listen: false);
    service.fetchCars(
      page: page,
      search: carSearchController.text,
      brandId: brandFilter,
      sort: sortField,
      order: sortOrder,
    );
  }

  void onBrandSearchChanged(String value) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchBrands();
    });
  }

  void onCarSearchChanged(String value) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchCars();
    });
  }

  void onBrandFilterChanged(int? val) {
    brandFilter = val;
    fetchCars();
    notifyListeners();
  }

  void toggleSort(String field) {
    if (sortField == field) {
      sortOrder = sortOrder == 'ASC' ? 'DESC' : 'ASC';
    } else {
      sortField = field;
      sortOrder = 'ASC';
    }
    fetchCars();
    notifyListeners();
  }

  Future<void> toggleCarStatus(AdminCarItem car) async {
    final service = Provider.of<AdminVehicleService>(context, listen: false);
    await service.updateCar(car.id, {'status': car.status == 1 ? 0 : 1});
  }

  Future<void> deleteBrand(int id) async {
    final service = Provider.of<AdminVehicleService>(context, listen: false);
    await service.deleteBrand(id);
  }

  Future<void> deleteCar(int id) async {
    final service = Provider.of<AdminVehicleService>(context, listen: false);
    await service.deleteCar(id);
  }

  @override
  void dispose() {
    brandSearchController.dispose();
    carSearchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }
}
