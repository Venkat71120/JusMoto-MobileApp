import 'dart:io';
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminCatalogService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class AdminCategoryFormView extends StatefulWidget {
  final dynamic category;
  const AdminCategoryFormView({super.key, this.category});

  @override
  State<AdminCategoryFormView> createState() => _AdminCategoryFormViewState();
}

class _AdminCategoryFormViewState extends State<AdminCategoryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _status = true;
  File? _selectedImage;

  bool get isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.category.name;
      _status = widget.category.status == 1;
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedImage = File(result.files.single.path!));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final service = Provider.of<AdminCatalogService>(context, listen: false);

    final Map<String, String> data = {
      'name': _nameController.text.trim(),
      'status': _status ? '1' : '0',
    };

    bool success;
    if (isEdit) {
      success = await service.updateCategory(widget.category.id, data, _selectedImage);
    } else {
      success = await service.createCategory(data, _selectedImage);
    }

    setState(() => _isLoading = false);
    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Category' : 'Add Category', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              24.toHeight,
              _buildLabel('Category Name'),
              TextFormField(
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
                decoration: _inputDecoration('e.g. Mechanical Repair', Icons.category_outlined),
              ),
              const SizedBox(height: 24),
              const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active Status', style: TextStyle(fontSize: 14)),
                value: _status,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _status = v),
              ),
              40.toHeight,
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEdit ? 'Update Category' : 'Create Category', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Icon / Image'),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _selectedImage != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                : isEdit && widget.category.image != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.category.image!, fit: BoxFit.cover))
                    : Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
