import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminReviewService.dart';
import '../../models/admin_models/AdminReviewModels.dart';

class AdminReviewViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminReviewViewModel(this.context);

  String _statusFilter = ''; // All statuses by default
  String get statusFilter => _statusFilter;

  void initReviews() {
    fetchReviews();
  }

  void fetchReviews({int page = 1}) {
    final service = Provider.of<AdminReviewService>(context, listen: false);
    service.fetchReviews(page: page, status: _statusFilter);
  }

  void setFilter(String val) {
    if (_statusFilter == val) return;
    _statusFilter = val;
    fetchReviews(page: 1);
    notifyListeners();
  }

  Future<void> updateStatus(AdminReviewItem review, String status) async {
    final service = Provider.of<AdminReviewService>(context, listen: false);
    await service.updateStatus(review.id, status);
  }

  Future<void> deleteReview(int id) async {
    final service = Provider.of<AdminReviewService>(context, listen: false);
    await service.deleteReview(id);
  }
}
