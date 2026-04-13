import 'dart:io';
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminVehicleService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class AdminCarFormView extends StatefulWidget {
  final dynamic car;
  const AdminCarFormView({super.key, this.car});

  @override
  State<AdminCarFormView> createState() => _AdminCarFormViewState();
}

class _AdminCarFormViewState extends State<AdminCarFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  
  int? _selectedBrandId;
  bool _status = true;
  bool _isLoading = false;
  File? _selectedImage;

  bool get isEdit => widget.car != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<AdminVehicleService>(context, listen: false).fetchBrands();
    });

    if (isEdit) {
      _nameController.text = widget.car.name;
      _yearController.text = widget.car.year ?? '';
      _selectedBrandId = widget.car.brandId;
      _status = widget.car.status == 1;
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedImage = File(result.files.single.path!));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedBrandId == null) {
      if (_selectedBrandId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a brand')));
      }
      return;
    }

    setState(() => _isLoading = true);
    final service = Provider.of<AdminVehicleService>(context, listen: false);

    final Map<String, String> data = {
      'name': _nameController.text.trim(),
      'brand_id': _selectedBrandId.toString(),
      'year': _yearController.text.trim(),
      'status': _status ? '1' : '0',
    };

    bool success;
    if (isEdit) {
      success = await service.updateCar(widget.car.id, data, _selectedImage);
    } else {
      success = await service.createCar(data, _selectedImage);
    }

    setState(() => _isLoading = false);
    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Car' : 'Add Car', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              _buildBrandDropdown(),
              20.toHeight,
              _buildTextField(
                controller: _nameController,
                label: 'Car Name / Model',
                hint: 'e.g. Camry',
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              20.toHeight,
              _buildTextField(
                controller: _yearController,
                label: 'Year',
                hint: 'e.g. 2024',
                keyboardType: TextInputType.number,
              ),
              24.toHeight,
              const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      : Text(isEdit ? 'Update Car' : 'Create Car', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vehicle Brand', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        8.toHeight,
        Consumer<AdminVehicleService>(
          builder: (context, service, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedBrandId,
                  hint: const Text('Select Brand'),
                  isExpanded: true,
                  items: service.brandList.brands.map((b) {
                    return DropdownMenuItem<int>(
                      value: b.id,
                      child: Text(b.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedBrandId = val),
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
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Car Image', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                : isEdit && widget.car.image != null
                    ? Image.network(widget.car.image!, fit: BoxFit.cover)
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
}
