import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminMarketingViewModel.dart';
import 'package:car_service/services/admin_services/AdminMarketingService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminCouponFormView.dart';
import 'package:intl/intl.dart';

class AdminCouponListView extends StatefulWidget {
  const AdminCouponListView({super.key});

  @override
  State<AdminCouponListView> createState() => _AdminCouponListViewState();
}

class _AdminCouponListViewState extends State<AdminCouponListView> {
  late AdminMarketingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminMarketingViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Coupons', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<AdminMarketingService>(
        builder: (context, service, child) {
          if (service.loading && service.couponList.coupons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.couponList.coupons.isEmpty) {
            return const Center(child: Text('No coupons found'));
          }

          return RefreshIndicator(
            onRefresh: () async => _viewModel.initCoupons(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: service.couponList.coupons.length,
              itemBuilder: (context, index) {
                final coupon = service.couponList.coupons[index];
                return _buildCouponCard(coupon);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminCouponFormView()),
          ).then((_) => _viewModel.initCoupons());
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCouponCard(coupon) {
    final bool expired = coupon.isExpired;
    final String formattedDate = coupon.expireDate != null 
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(coupon.expireDate)) 
        : 'No Expiry';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: Text(
                    coupon.code,
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
                const Spacer(),
                _buildBadge(
                  coupon.discountType == 'percentage' 
                      ? '${coupon.discount.toInt()}% OFF' 
                      : '\u20B9${coupon.discount.toInt()} OFF',
                  coupon.discountType == 'percentage' ? Colors.blue : Colors.purple,
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(coupon.title ?? 'Untitled Coupon', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: expired ? Colors.red : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: $formattedDate',
                      style: TextStyle(fontSize: 12, color: expired ? Colors.red : Colors.grey[600], fontWeight: expired ? FontWeight.bold : FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusToggle(coupon),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminCouponFormView(coupon: coupon)),
                        ).then((_) => _viewModel.initCoupons());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _showDeleteDialog(coupon),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(coupon) {
    return InkWell(
      onTap: () => _viewModel.toggleCouponStatus(coupon),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: coupon.status == 1 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: coupon.status == 1 ? Colors.green : Colors.red),
            const SizedBox(width: 6),
            Text(
              coupon.status == 1 ? 'Active' : 'Inactive',
              style: TextStyle(color: coupon.status == 1 ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showDeleteDialog(coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete coupon ${coupon.code}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteCoupon(coupon.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
