import 'dart:io';
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminMediaService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class AdminMediaLibraryView extends StatefulWidget {
  final bool isSelectionMode;
  const AdminMediaLibraryView({super.key, this.isSelectionMode = false});

  @override
  State<AdminMediaLibraryView> createState() => _AdminMediaLibraryViewState();
}

class _AdminMediaLibraryViewState extends State<AdminMediaLibraryView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminMediaService>(context, listen: false).fetchMedia();
    });
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
    if (result != null) {
      final service = Provider.of<AdminMediaService>(context, listen: false);
      for (final file in result.files) {
        if (file.path != null) {
          await service.uploadMedia(File(file.path!));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Media Library', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: _pickAndUpload,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<AdminMediaService>(
              builder: (context, service, child) {
                if (service.loading && service.mediaList.media.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (service.mediaList.media.isEmpty) {
                  return const Center(child: Text('No media files found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => service.fetchMedia(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: service.mediaList.media.length + (service.mediaList.pagination.hasNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == service.mediaList.media.length) {
                        service.fetchMedia(page: service.mediaList.pagination.currentPage + 1);
                        return const Center(child: CircularProgressIndicator());
                      }

                      final item = service.mediaList.media[index];
                      return _buildMediaItem(item);
                    },
                  ),
                );
              },
            ),
          ),
          if (Provider.of<AdminMediaService>(context).uploading)
            const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search media...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.zero,
        ),
        onSubmitted: (val) {
          Provider.of<AdminMediaService>(context, listen: false).fetchMedia(search: val);
        },
      ),
    );
  }

  Widget _buildMediaItem(item) {
    return InkWell(
      onTap: () {
        if (widget.isSelectionMode) {
          Navigator.pop(context, item);
        } else {
          _showDetailDialog(item);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.thumbUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => _confirmDelete(item),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 14, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(item.path, fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('ID: #${item.id}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmDelete(item);
                        },
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: const Text('This will permanently delete this image. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AdminMediaService>(context, listen: false).deleteMedia(item.id);
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
    _searchController.dispose();
    super.dispose();
  }
}
