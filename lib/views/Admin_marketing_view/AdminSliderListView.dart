import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/view_models/admin_view_models/AdminMarketingViewModel.dart';
import 'package:car_service/services/admin_services/AdminMarketingService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AdminSliderFormView.dart';

class AdminSliderListView extends StatefulWidget {
  const AdminSliderListView({super.key});

  @override
  State<AdminSliderListView> createState() => _AdminSliderListViewState();
}

class _AdminSliderListViewState extends State<AdminSliderListView> {
  late AdminMarketingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminMarketingViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initSliders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        title: const Text('Homepage Sliders', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<AdminMarketingService>(
        builder: (context, service, child) {
          if (service.loading && service.sliderList.sliders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.sliderList.sliders.isEmpty) {
            return const Center(child: Text('No sliders found'));
          }

          return RefreshIndicator(
            onRefresh: () async => _viewModel.fetchSliders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: service.sliderList.sliders.length,
              itemBuilder: (context, index) {
                final slider = service.sliderList.sliders[index];
                return _buildSliderCard(slider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminSliderFormView()),
          ).then((_) => _viewModel.fetchSliders());
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSliderCard(slider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            clipBehavior: Clip.antiAlias,
            child: slider.image != null
                ? Image.network(slider.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.grey))
                : const Icon(Icons.image, size: 50, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slider.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (slider.link != null && slider.link!.isNotEmpty)
                        Text(slider.link!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildSwitch(slider),
                    8.toWidth,
                    _buildMoreMenu(slider),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(slider) {
    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: slider.status == 1,
        activeColor: primaryColor,
        onChanged: (v) => _viewModel.toggleSliderStatus(slider),
      ),
    );
  }

  Widget _buildMoreMenu(slider) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      padding: EdgeInsets.zero,
      onSelected: (val) {
        if (val == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminSliderFormView(slider: slider)),
          ).then((_) => _viewModel.fetchSliders());
        } else if (val == 'delete') {
          _showDeleteDialog(slider);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit Slider')),
        const PopupMenuItem(value: 'delete', child: Text('Delete Slider', style: TextStyle(color: Colors.red))),
      ],
    );
  }

  void _showDeleteDialog(slider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Slider', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete "${slider.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteSlider(slider.id);
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
