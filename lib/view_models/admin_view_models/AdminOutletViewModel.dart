import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminOutletService.dart';
import '../../models/admin_models/AdminOutletModels.dart';

class AdminOutletViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminOutletViewModel(this.context);

  void initOutlets() {
    final service = Provider.of<AdminOutletService>(context, listen: false);
    service.fetchOutlets();
  }

  Future<void> toggleStatus(AdminOutletItem outlet) async {
    final service = Provider.of<AdminOutletService>(context, listen: false);
    await service.updateOutlet(outlet.id, {'status': outlet.status == 1 ? 0 : 1});
  }

  Future<void> deleteOutlet(int id) async {
    final service = Provider.of<AdminOutletService>(context, listen: false);
    await service.deleteOutlet(id);
  }
}
