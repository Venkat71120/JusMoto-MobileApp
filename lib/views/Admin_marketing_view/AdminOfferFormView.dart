import 'dart:io';
import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminMarketingService.dart';
import 'package:car_service/services/admin_services/AdminCatalogService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class AdminOfferFormView extends StatefulWidget {
  final dynamic offer;
  const AdminOfferFormView({super.key, this.offer});

  @override
  State<AdminOfferFormView> createState() => _AdminOfferFormViewState();
}

class _AdminOfferFormViewState extends State<AdminOfferFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _discountController = TextEditingController();
  final _expiryController = TextEditingController();
  
  bool _status = true;
  bool _isPrimary = false;
  bool _isLoading = false;
  DateTime? _selectedExpiry;
  File? _selectedImage;
  List<int> _selectedServiceIds = [];

  bool get isEdit => widget.offer != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminCatalogService>(context, listen: false).fetchServices(page: 1);
    });

    if (isEdit) {
      _titleController.text = widget.offer.title;
      _discountController.text = widget.offer.offerPercentage.toString();
      _status = widget.offer.status == 1;
      _isPrimary = widget.offer.isPrimary == 1;
      _selectedServiceIds = List<int>.from(widget.offer.serviceIds ?? []);
      
      if (widget.offer.expiresAt != null) {
        _selectedExpiry = DateTime.parse(widget.offer.expiresAt);
        _expiryController.text = DateFormat('yyyy-MM-dd').format(_selectedExpiry!);
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedImage = File(result.files.single.path!));
    }
  }

  Future<void> _selectExpiry(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiry ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiry = picked;
        _expiryController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final service = Provider.of<AdminMarketingService>(context, listen: false);

    final Map<String, String> data = {
      'title': _titleController.text.trim(),
      'offerPercentage': _discountController.text.trim(),
      'expires_at': _selectedExpiry != null ? DateFormat('yyyy-MM-dd').format(_selectedExpiry!) : '',
      'status': _status ? '1' : '0',
      'is_primary': _isPrimary ? '1' : '0',
    };

    bool success;
    if (isEdit) {
      success = await service.updateOffer(widget.offer.id, data, _selectedImage, _selectedServiceIds);
    } else {
      success = await service.createOffer(data, _selectedImage, _selectedServiceIds);
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
        title: Text(isEdit ? 'Edit Offer' : 'Add Offer', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                label: 'Offer Headline / Title',
                hint: 'e.g. Grand Opening Sale!',
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              20.toHeight,
              _buildTextField(
                controller: _discountController,
                label: 'Offer Discount (%)',
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Discount is required';
                  final n = double.tryParse(v);
                  if (n == null || n < 0 || n > 100) return 'Invalid percentage (0-100)';
                  return null;
                },
              ),
              20.toHeight,
              _buildExpiryPicker(),
              24.toHeight,
              _buildServiceSelector(),
              24.toHeight,
               const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              CheckboxListTile(
                 contentPadding: EdgeInsets.zero,
                title: const Text('Primary Offer (Shows on Home)', style: TextStyle(fontSize: 14)),
                value: _isPrimary,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _isPrimary = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
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
                      : Text(isEdit ? 'Update Offer' : 'Create Offer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
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
        const Text('Banner Image', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        8.toHeight,
        InkWell(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _selectedImage != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                : isEdit && widget.offer.image != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(widget.offer.image!, fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('Upload promo banner', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attached Services', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        8.toHeight,
        Consumer<AdminCatalogService>(
          builder: (context, service, _) {
            final services = service.serviceList.services.where((element) => element.type == 0).toList(); // Only services, not products
            if (services.isEmpty) return const Text('No services available to link', style: TextStyle(color: Colors.grey, fontSize: 12));
            
            return Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final s = services[index];
                  final isSelected = _selectedServiceIds.contains(s.id);
                  return CheckboxListTile(
                    title: Text(s.title, style: const TextStyle(fontSize: 13)),
                    subtitle: Text('\u20B9${s.price}', style: const TextStyle(fontSize: 11)),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedServiceIds.add(s.id);
                        } else {
                          _selectedServiceIds.remove(s.id);
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpiryPicker() {
    return InkWell(
      onTap: () => _selectExpiry(context),
      child: IgnorePointer(
        child: _buildTextField(
          controller: _expiryController,
          label: 'Expiration Date',
          hint: 'Select expiration date',
          suffixIcon: const Icon(Icons.calendar_month),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
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
            suffixIcon: suffixIcon,
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
    _discountController.dispose();
    _expiryController.dispose();
    super.dispose();
  }
}
