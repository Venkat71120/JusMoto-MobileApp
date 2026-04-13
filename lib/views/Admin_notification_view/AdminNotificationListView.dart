import 'package:car_service/views/Admin_notification_view/AdminNotificationFormView.dart';
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminNotificationViewModel.dart';
import 'package:car_service/services/admin_services/AdminNotificationService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminNotificationListView extends StatefulWidget {
  const AdminNotificationListView({super.key});

  @override
  State<AdminNotificationListView> createState() => _AdminNotificationListViewState();
}

class _AdminNotificationListViewState extends State<AdminNotificationListView> {
  late AdminNotificationViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = AdminNotificationViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _viewModel.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<AdminNotificationService>(
        builder: (context, service, child) {
          if (service.loading && service.notificationList.data.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.notificationList.data.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications found', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _viewModel.init(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: service.notificationList.data.length + (service.loading ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == service.notificationList.data.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                }

                final notification = service.notificationList.data[index];
                return _buildNotificationCard(notification);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminNotificationFormView())).then((_) => _viewModel.init()),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text('Send Broadcast', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildNotificationCard(notification) {
    final bool isUnread = !notification.isRead;

    return InkWell(
      onTap: isUnread ? () => _viewModel.markAsRead(notification) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isUnread ? primaryColor.withOpacity(0.2) : Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconColor(notification.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(notification.type), color: _getIconColor(notification.type), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTypeLabel(notification.type),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getIconColor(notification.type),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        timeago.format(notification.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnread ? Colors.black : Colors.grey[700],
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _viewModel.markAsRead(notification),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: primaryColor,
                        ),
                        child: const Text('Mark as read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    if (type == null) return Icons.notifications;
    final t = type.toLowerCase();
    if (t.contains('order')) return Icons.shopping_bag;
    if (t.contains('status')) return Icons.info_outline;
    if (t.contains('franchise')) return Icons.business;
    if (t.contains('chat')) return Icons.chat;
    return Icons.notifications;
  }

  Color _getIconColor(String? type) {
    if (type == null) return Colors.blue;
    final t = type.toLowerCase();
    if (t.contains('order')) return Colors.orange;
    if (t.contains('status')) return Colors.blue;
    if (t.contains('franchise')) return Colors.purple;
    if (t.contains('chat')) return Colors.green;
    return Colors.blue;
  }

  String _getTypeLabel(String? type) {
    if (type == null) return 'Alert';
    return type.replaceAll('_', ' ').toUpperCase();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
