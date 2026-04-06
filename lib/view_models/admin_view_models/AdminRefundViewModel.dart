import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminRefundService.dart';
import '../../models/admin_models/AdminRefundModels.dart';

class AdminRefundViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminRefundViewModel(this.context);

  int _selectedStatus = -1; // -1 = All
  int get selectedStatus => _selectedStatus;

  void init() {
    final service = Provider.of<AdminRefundService>(context, listen: false);
    service.fetchRefunds(page: 1);
  }

  void setFilter(int status) {
    _selectedStatus = status;
    final service = Provider.of<AdminRefundService>(context, listen: false);
    service.fetchRefunds(page: 1, status: status == -1 ? '' : status.toString());
    notifyListeners();
  }

  void loadMore() {
    final service = Provider.of<AdminRefundService>(context, listen: false);
    final pagination = service.refundList.pagination;
    if (pagination != null && pagination.hasNextPage) {
      service.fetchRefunds(page: pagination.page + 1, status: _selectedStatus == -1 ? '' : _selectedStatus.toString());
    }
  }

  Future<void> updateStatus(AdminRefundItem refund, int newStatus) async {
    final service = Provider.of<AdminRefundService>(context, listen: false);
    await service.updateRefundStatus(refund.id, newStatus);
  }
}
