import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminCatalogService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      _discountPriceController.text = widget.item.discountPrice?.toString() ?? '';
      _durationController.text = widget.item.duration ?? '';
      _descriptionController.text = widget.item.description ?? '';
      _selectedCategoryId = widget.item.categoryId;
      _isFeatured = widget.item.isFeatured == 1;
      _status = widget.item.status == 1;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final service = Provider.of<AdminCatalogService>(context, listen: false);

    final data = {
      'title': _titleController.text.trim(),
      'category_id': _selectedCategoryId,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'discount_price': _discountPriceController.text.isNotEmpty ? double.tryParse(_discountPriceController.text) : null,
      'duration': _durationController.text.trim(),
      'description': _descriptionController.text.trim(),
      'is_featured': _isFeatured ? 1 : 0,
      'status': _status ? 1 : 0,
      'type': widget.itemType,
    };

    bool success;
    if (isEdit) {
      success = await service.updateService(widget.item.id, data);
    } else {
      success = await service.createService(data);
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
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Price is required' : null,
                    ),
                  ),
                  16.toWidth,
                  Expanded(
                    child: _buildTextField(
                      controller: _discountPriceController,
                      label: 'Discount Price (\u20B9)',
                      hint: '0.00',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              20.toHeight,
              _buildTextField(
                controller: _durationController,
                label: 'Duration / Size',
                hint: 'e.g. 30 mins or 500ml',
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
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
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
