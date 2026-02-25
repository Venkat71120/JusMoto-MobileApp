// ─────────────────────────────────────────────────────────────────────────────
// VIEW-MODEL: franchise_home_view_model.dart
// Location: lib/view_models/franchise_home_view_model/franchise_home_view_model.dart
//
// Follows the EXACT singleton pattern of HomeViewModel with appBarSize for scroll animation
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// Tabs available on the earnings section of the dashboard.
enum EarningsPeriod { today, week, month, all }

class FranchiseHomeViewModel {
  // ── Notifiers ─────────────────────────────────────────────────────────────
  final ScrollController scrollController = ScrollController();

  /// ✅ Controls AppBar color animation based on scroll (same as HomeViewModel)
  final ValueNotifier<double> appBarSize = ValueNotifier(0);

  /// Controls which earning period tab is selected.
  final ValueNotifier<EarningsPeriod> earningsPeriod =
      ValueNotifier(EarningsPeriod.all);

  /// Controls which activity tab is active (orders / tickets).
  final ValueNotifier<int> activityTab = ValueNotifier(0);

  // ── Singleton ─────────────────────────────────────────────────────────────
  FranchiseHomeViewModel._init();
  static FranchiseHomeViewModel? _instance;
  static FranchiseHomeViewModel get instance {
    _instance ??= FranchiseHomeViewModel._init();
    return _instance!;
  }

  FranchiseHomeViewModel._dispose();
  static bool get dispose {
    _instance?.scrollController.dispose();
    _instance?.appBarSize.dispose();
    _instance?.earningsPeriod.dispose();
    _instance?.activityTab.dispose();
    _instance = null;
    return true;
  }
}