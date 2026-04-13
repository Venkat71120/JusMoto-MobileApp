import 'dart:io';
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminCatalogService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class AdminServiceFormView extends StatefulWidget {
  final int itemType; // 0=Service, 1=Product
  final dynamic item;
  const AdminServiceFormView({super.key, required this.itemType, this.item});

  @override
  State<AdminServiceFormView> createState() => _AdminServiceFormViewState();
}

class _AdminServiceFormViewState extends State<AdminServiceFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedCategoryId;
  bool _isFeatured = false;
  bool _status = true;
  bool _isLoading = false;
  File? _selectedImage;

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<AdminCatalogService>(context, listen: false).fetchCategories();
    });

    if (isEdit) {
      _titleController.text = widget.item.title;
      _priceController.text = widget.item.price.toString();
      _discountPriceController.text = (widget.item.discountPrice != null && widget.item.discountPrice! > 0) ? widget.item.discountPrice.toString() : '';
      _durationController.text = widget.item.duration ?? '';
      _descriptionController.text = widget.item.description ?? '';
      _selectedCategoryId = widget.item.categoryId;
      _isFeatured = widget.item.isFeatured == 1;
      _status = widget.item.status == 1;
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
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final dPrice = _discountPriceController.text.isNotEmpty ? double.tryParse(_discountPriceController.text) : 0.0;

    if (dPrice != null && dPrice >= price) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Discount price must be less than the regular price')));
      return;
    }

    setState(() => _isLoading = true);
    final service = Provider.of<AdminCatalogService>(context, listen: false);

    // Multipart fields must be Strings
    final Map<String, String> data = {
      'title': _titleController.text.trim(),
      'category_id': _selectedCategoryId.toString(),
      'price': price.toString(),
      'discount_price': dPrice?.toString() ?? '0',
      'duration': _durationController.text.trim(),
      'description': _descriptionController.text.trim(),
      'is_featured': _isFeatured ? '1' : '0',
      'status': _status ? '1' : '0',
      'type': widget.itemType.toString(),
    };

    bool success;
    if (isEdit) {
      success = await service.updateService(widget.item.id, data, _selectedImage);
    } else {
      success = await service.createService(data, _selectedImage);
    }

    setState(() => _isLoading = false);
    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = widget.itemType == 0 ? 'Service' : 'Product';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit $typeLabel' : 'Add $typeLabel', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              24.toHeight,
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter $typeLabel title',
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              20.toHeight,
              _buildCategoryDropdown(),
              20.toHeight,
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price (\u20B9)',
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v!.isEmpty) return 'Price is required';
                        final p = double.tryParse(v);
                        if (p == null) return 'Invalid price';
                        if (p <= 0) return 'Price must be greater than 0';
                        return null;
                      },
                    ),
                  ),
                  16.toWidth,
                  Expanded(
                    child: _buildTextField(
                      controller: _discountPriceController,
                      label: 'Discount Price (\u20B9)',
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Invalid format';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              20.toHeight,
              _buildTextField(
                controller: _durationController,
                label: widget.itemType == 0 ? 'Duration' : 'Size / Specs',
                hint: widget.itemType == 0 ? 'e.g. 30 mins' : 'e.g. 500ml or 1kg',
              ),
              20.toHeight,
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter detailed description',
                maxLines: 4,
              ),
              24.toHeight,
              const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Highlighted / Featured', style: TextStyle(fontSize: 14)),
                value: _isFeatured,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active / Publicly Visible', style: TextStyle(fontSize: 14)),
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
                      : Text(isEdit ? 'Update $typeLabel' : 'Create $typeLabel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
              20.toHeight,
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
        const Text('Display Image', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        8.toHeight,
        InkWell(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : isEdit && widget.item.image != null
                    ? Image.network(widget.item.image!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('Upload image', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        8.toHeight,
        Consumer<AdminCatalogService>(
          builder: (context, service, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedCategoryId,
                  hint: const Text('Select Category'),
                  isExpanded: true,
                  items: service.categoryList.categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        8.toHeight,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
