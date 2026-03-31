import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminDashboardService.dart';

class AdminHomeViewModel {
  AdminHomeViewModel._init();
  static AdminHomeViewModel? _instance;
  static AdminHomeViewModel get instance {
    _instance ??= AdminHomeViewModel._init();
    return _instance!;
  }

  static bool get dispose {
    _instance = null;
    return true;
  }

  Future<void> onRefresh(BuildContext context) async {
    await Provider.of<AdminDashboardService>(context, listen: false).fetchDashboardData();
  }

  Future<void> init(BuildContext context) async {
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardService>(context, listen: false).fetchDashboardData();
    });
  }
}
