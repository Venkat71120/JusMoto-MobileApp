import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/Admin_home_view_model/AdminHomeViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_services/AdminDashboardService.dart';
import '../../helper/extension/int_extension.dart';
import '../Admin_franchise_view/AdminFranchiseListView.dart';
import '../Admin_catalog_view/AdminServiceListView.dart';
import '../Admin_catalog_view/AdminCategoryListView.dart';
import '../Admin_vehicle_view/AdminBrandListView.dart';
import '../Admin_vehicle_view/AdminCarListView.dart';
import 'package:car_service/views/Admin_marketing_view/AdminCouponListView.dart';
import 'package:car_service/views/Admin_marketing_view/AdminOfferListView.dart';
import 'package:car_service/views/Admin_review_view/AdminReviewListView.dart';
import 'package:car_service/views/Admin_outlet_view/AdminOutletListView.dart';
import 'package:car_service/views/Admin_report_view/AdminReportListView.dart';
import 'package:car_service/views/Admin_notification_view/AdminNotificationListView.dart';
import 'package:car_service/views/Admin_refund_view/AdminRefundListView.dart';
import 'package:car_service/views/Admin_quotes_view/admin_quote_list_view.dart';
import 'package:car_service/views/Admin_user_view/AdminUserManagementView.dart';
import 'package:car_service/views/Admin_vehicle_view/AdminVariantListView.dart';
import 'package:car_service/views/Admin_vehicle_view/AdminEngineTypeListView.dart';
import 'package:car_service/views/Admin_vehicle_view/AdminFuelTypeListView.dart';
import 'package:car_service/views/Admin_marketing_view/AdminSliderListView.dart';
import 'package:car_service/views/Admin_marketing_view/AdminMediaLibraryView.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  @override
  void initState() {
    super.initState();
    AdminHomeViewModel.instance.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.color.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AdminDashboardService>(
        builder: (context, service, child) {
          if (service.loading && service.dashboardData.totalOrders == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = service.dashboardData;

          return RefreshIndicator(
            onRefresh: () => AdminHomeViewModel.instance.onRefresh(context),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Key Metrics Grid ---
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildStatCard(
                        context,
                        'Total Revenue',
                        '\u20B9${data.totalRevenue.toStringAsFixed(0)}',
                        Icons.payments,
                        Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        'Total Orders',
                        '${data.totalOrders}',
                        Icons.shopping_cart,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        "Today's Orders",
                        '${data.todayOrders}',
                        Icons.today,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        context,
                        'Pending Orders',
                        '${data.pendingOrders}',
                        Icons.pending_actions,
                        Colors.red,
                      ),
                    ],
                  ),

                  32.toHeight,

                  // --- Status Distribution ---
                  const Text(
                    'Order Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  16.toHeight,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children:
                          data.ordersByStatus.map((status) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      _getStatusText(status.status),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value:
                                            data.totalOrders > 0
                                                ? status.count /
                                                    data.totalOrders
                                                : 0,
                                        backgroundColor: Colors.grey[200],
                                        color: _getStatusColor(status.status),
                                        minHeight: 10,
                                      ),
                                    ),
                                  ),
                                  12.toWidth,
                                  Text(
                                    '${status.count}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  32.toHeight,

                  Row(
                    children: [
                      _buildSmallStat(
                        context,
                        'Users',
                        data.totalUsers,
                        Icons.person,
                        Colors.purple,
                      ),
                      16.toWidth,
                      _buildSmallStat(
                        context,
                        'Services',
                        data.totalServices,
                        Icons.engineering,
                        Colors.amber,
                      ),
                      16.toWidth,
                      _buildSmallStat(
                        context,
                        'Cars',
                        data.totalCars,
                        Icons.directions_car,
                        Colors.cyan,
                      ),
                    ],
                  ),

                  32.toHeight,

                  const Text(
                    'Quick Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  16.toHeight,
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      _buildManagementCard(
                        context,
                        'Franchises',
                        Icons.business_center,
                        Colors.indigo,
                        const AdminFranchiseListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Services',
                        Icons.engineering,
                        Colors.amber,
                        const AdminServiceListView(itemType: 0),
                      ),
                      _buildManagementCard(
                        context,
                        'Products',
                        Icons.shopping_bag,
                        Colors.teal,
                        const AdminServiceListView(itemType: 1),
                      ),
                      _buildManagementCard(
                        context,
                        'Categories',
                        Icons.category,
                        Colors.orange,
                        const AdminCategoryListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Brands',
                        Icons.stars,
                        Colors.blue,
                        const AdminBrandListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Cars',
                        Icons.directions_car,
                        Colors.purple,
                        const AdminCarListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Coupons',
                        Icons.confirmation_number,
                        Colors.redAccent,
                        const AdminCouponListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Offers',
                        Icons.local_offer,
                        Colors.pink,
                        const AdminOfferListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Reviews',
                        Icons.rate_review,
                        Colors.amber,
                        const AdminReviewListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Outlets',
                        Icons.store_mall_directory,
                        Colors.teal,
                        const AdminOutletListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Reports',
                        Icons.analytics,
                        Colors.deepPurple,
                        const AdminReportListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Notifications',
                        Icons.notifications_active,
                        Colors.orange,
                        const AdminNotificationListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Refunds',
                        Icons.currency_exchange,
                        Colors.redAccent,
                        const AdminRefundListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Admins',
                        Icons.admin_panel_settings,
                        Colors.indigo,
                        const AdminUserManagementView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Users',
                        Icons.people,
                        Colors.blue,
                        const AdminUserManagementView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Quotes',
                        Icons.request_quote,
                        Colors.blueGrey,
                        const AdminQuoteListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Media',
                        Icons.image,
                        Colors.orange,
                        const AdminMediaLibraryView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Sliders',
                        Icons.slideshow,
                        Colors.blue,
                        const AdminSliderListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Variants',
                        Icons.layers,
                        Colors.deepOrange,
                        const AdminVariantListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Engines',
                        Icons.settings_input_component,
                        Colors.brown,
                        const AdminEngineTypeListView(),
                      ),
                      _buildManagementCard(
                        context,
                        'Fuels',
                        Icons.local_gas_station,
                        Colors.green,
                        const AdminFuelTypeListView(),
                      ),
                    ],
                  ),

                  32.toHeight,
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  16.toHeight,
                  if (data.recentOrders.isEmpty)
                    const Center(child: Text('No recent orders found'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.recentOrders.length,
                      itemBuilder: (context, index) {
                        final order = data.recentOrders[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryColor.withOpacity(0.1),
                              child: Text(
                                order.firstName.isNotEmpty
                                    ? order.firstName[0]
                                    : '?',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text('${order.firstName} ${order.lastName}'),
                            subtitle: Text(order.email),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\u20B9${order.total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _getStatusText(order.status),
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  32.toHeight,

                  const Text(
                    'Recent Users',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  16.toHeight,
                  if (data.recentUsers.isEmpty)
                    const Center(child: Text('No recent users found'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.recentUsers.length,
                      itemBuilder: (context, index) {
                        final user = data.recentUsers[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.person, color: Colors.grey[600]),
                          ),
                          title: Text('${user.firstName} ${user.lastName}'),
                          subtitle: Text(user.email),
                          trailing: Text(
                            user.createdAt.split('T')[0],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),

                  32.toHeight,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          8.toHeight,
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSmallStat(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            4.toHeight,
            Text(
              '$value',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Completed';
      case 3:
        return 'Delivered';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.teal;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: context.color.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.12), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: context.color.primaryContrastColor.withOpacity(0.8),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
