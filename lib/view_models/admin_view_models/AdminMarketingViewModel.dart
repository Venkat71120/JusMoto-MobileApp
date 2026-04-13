import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminMarketingService.dart';
import '../../models/admin_models/admin_marketing_models.dart';

class AdminMarketingViewModel extends ChangeNotifier {
  final BuildContext context;
  AdminMarketingViewModel(this.context);

  void initCoupons() {
    final service = Provider.of<AdminMarketingService>(context, listen: false);
    service.fetchCoupons();
  }

  void initOffers() {
    final service = Provider.of<AdminMarketingService>(context, listen: false);
    service.fetchOffers();
  }

  Future<void> toggleCouponStatus(AdminCouponItem coupon) async {
    final service = Provider.of<AdminMarketingService>(context, listen: false);
    await service.updateCoupon(coupon.id, {'status': coupon.status == 1 ? 0 : 1});
  }

  Future<void> toggleOfferStatus(AdminOfferItem offer) async {
    final service = Provider.of<AdminMarketingService>(context, listen: false);
    // updateOffer expects Map<String, String>, null image, and List<int> serviceIds
    await service.updateOffer(
      offer.id, 
      {'status': offer.status == 1 ? '0' : '1'}, 
      null, 
      List<int>.from(offer.serviceIds)
    );
  }

  Future<void> deleteCoupon(int id) async {
    final service = Provider.of<AdminMarketingService>(context, listen: false);
    await service.deleteCoupon(id);
  }

  Future<void> deleteOffer(int id) async {
    final service = Provider.of<AdminMarketingService>(context, listen: false);
    await service.deleteOffer(id);
  }
}
