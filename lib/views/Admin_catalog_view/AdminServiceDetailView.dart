import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';

class AdminServiceDetailView extends StatelessWidget {
  final dynamic item;
  final int itemType; // 0=Service, 1=Product

  const AdminServiceDetailView({super.key, required this.item, required this.itemType});

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = item.discountPrice != null && item.discountPrice! > 0;
    final typeLabel = itemType == 0 ? 'Service' : 'Product';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('$typeLabel Details', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  8.toHeight,
                  Text(
                    item.category?.name ?? 'No Category',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  20.toHeight,
                  _buildPriceSection(hasDiscount),
                  24.toHeight,
                  const Divider(),
                  24.toHeight,
                  _buildDetailRow(
                    icon: itemType == 0 ? Icons.access_time : Icons.straighten,
                    label: itemType == 0 ? 'Expected Duration' : 'Size / Specifications',
                    value: item.duration ?? 'N/A',
                  ),
                  20.toHeight,
                  _buildDescriptionSection(),
                  32.toHeight,
                  _buildAdditionalInfo(),
                  40.toHeight,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: item.image != null && item.image!.isNotEmpty
          ? Image.network(item.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80, color: Colors.grey))
          : const Icon(Icons.image, size: 80, color: Colors.grey),
    );
  }

  Widget _buildStatusBadge() {
    final bool isActive = item.status == 1;
    final Color color = isActive ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPriceSection(bool hasDiscount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pricing', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
              4.toHeight,
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\u20B9${hasDiscount ? item.discountPrice : item.price}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  if (hasDiscount) ...[
                    8.toWidth,
                    Text(
                      '\u20B9${item.price}',
                      style: TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Spacer(),
          if (item.isFeatured == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 14),
                  SizedBox(width: 4),
                  Text('Featured', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: Colors.grey[600]),
        ),
        16.toWidth,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        12.toHeight,
        Text(
          item.description ?? 'No description provided.',
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: primaryColor),
              8.toWidth,
              Text('System Metadata', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
            ],
          ),
          12.toHeight,
          _buildMetaRow('Service ID', '#${item.id}'),
          _buildMetaRow('System Name', item.title.toString().toLowerCase().replaceAll(' ', '_')),
          _buildMetaRow('Featured Status', item.isFeatured == 1 ? 'Enabled' : 'Disabled'),
          _buildMetaRow('Visibility', item.status == 1 ? 'Public' : 'Hidden'),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
