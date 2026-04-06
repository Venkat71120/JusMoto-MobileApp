import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminReviewViewModel.dart';
import 'package:car_service/services/admin_services/AdminReviewService.dart';
import 'package:car_service/models/admin_models/AdminReviewModels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminReviewListView extends StatefulWidget {
  const AdminReviewListView({super.key});

  @override
  State<AdminReviewListView> createState() => _AdminReviewListViewState();
}

class _AdminReviewListViewState extends State<AdminReviewListView> {
  late AdminReviewViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminReviewViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Reviews & Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<AdminReviewService>(
              builder: (context, service, child) {
                if (service.loading && service.reviewList.reviews.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.reviewList.reviews.isEmpty) {
                  return const Center(child: Text('No reviews found for this status'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _viewModel.fetchReviews(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.reviewList.reviews.length + (service.reviewList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.reviewList.reviews.length) {
                        _viewModel.fetchReviews(page: service.reviewList.pagination.currentPage + 1);
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                      }

                      final review = service.reviewList.reviews[index];
                      return _buildReviewCard(review);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('', 'All Statuses'),
            10.toWidth,
            _buildFilterChip('pending', 'Pending'),
            10.toWidth,
            _buildFilterChip('approved', 'Approved'),
            10.toWidth,
            _buildFilterChip('rejected', 'Rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _viewModel.statusFilter == value;
    return GestureDetector(
      onTap: () => _viewModel.setFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(AdminReviewItem review) {
    final bool isPending = review.status == 'pending';
    final bool isApproved = review.status == 'approved';
    final Color statusColor = isApproved ? Colors.green : (isPending ? Colors.orange : Colors.red);
    final String date = DateFormat('dd MMM yyyy').format(DateTime.parse(review.createdAt));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStarRating(review.rating),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    review.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.message,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user?.name ?? 'Anonymous User',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'for ${review.service?.name ?? 'General Service'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (review.status != 'approved')
                  _buildActionButton(
                    label: 'Approve',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onTap: () => _viewModel.updateStatus(review, 'approved'),
                  ),
                if (review.status != 'approved') 8.toWidth,
                if (review.status != 'rejected')
                   _buildActionButton(
                    label: 'Reject',
                    icon: Icons.cancel_outlined,
                    color: Colors.orange,
                    onTap: () => _viewModel.updateStatus(review, 'rejected'),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _showDeleteDialog(review),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey[300],
          size: 18,
        );
      }),
    );
  }

  void _showDeleteDialog(AdminReviewItem review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to delete this review? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteReview(review.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
