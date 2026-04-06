import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminMarketingViewModel.dart';
import 'package:car_service/services/admin_services/AdminMarketingService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminOfferFormView.dart';
import 'package:intl/intl.dart';

class AdminOfferListView extends StatefulWidget {
  const AdminOfferListView({super.key});

  @override
  State<AdminOfferListView> createState() => _AdminOfferListViewState();
}

class _AdminOfferListViewState extends State<AdminOfferListView> {
  late AdminMarketingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminMarketingViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Offers & Banners', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<AdminMarketingService>(
        builder: (context, service, child) {
          if (service.loading && service.offerList.offers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.offerList.offers.isEmpty) {
            return const Center(child: Text('No offers found'));
          }

          return RefreshIndicator(
            onRefresh: () async => _viewModel.initOffers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: service.offerList.offers.length,
              itemBuilder: (context, index) {
                final offer = service.offerList.offers[index];
                return _buildOfferCard(offer);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminOfferFormView()),
          ).then((_) => _viewModel.initOffers());
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOfferCard(offer) {
    final bool expired = offer.isExpired;
    final String formattedDate = offer.expiresAt != null 
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(offer.expiresAt)) 
        : 'Never';

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: offer.image != null
                    ? Image.network(offer.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.grey))
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: Text(
                    '${offer.offerPercentage.toInt()}% OFF',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: expired ? Colors.red : Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Expires: $formattedDate',
                          style: TextStyle(fontSize: 12, color: expired ? Colors.red : Colors.grey[600], fontWeight: expired ? FontWeight.bold : FontWeight.normal),
                        ),
                      ],
                    ),
                    _buildStatusToggle(offer),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminOfferFormView(offer: offer)),
                  ).then((_) => _viewModel.initOffers());
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showDeleteDialog(offer),
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                label: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(offer) {
    return InkWell(
      onTap: () => _viewModel.toggleOfferStatus(offer),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: offer.status == 1 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          offer.status == 1 ? 'Active' : 'Inactive',
          style: TextStyle(color: offer.status == 1 ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showDeleteDialog(offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete "${offer.title}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteOffer(offer.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
