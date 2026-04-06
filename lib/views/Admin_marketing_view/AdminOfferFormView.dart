import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminMarketingService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
  bool _isLoading = false;
  DateTime? _selectedExpiry;

  bool get isEdit => widget.offer != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _titleController.text = widget.offer.title;
      _discountController.text = widget.offer.offerPercentage.toString();
      _status = widget.offer.status == 1;
      
      if (widget.offer.expiresAt != null) {
        _selectedExpiry = DateTime.parse(widget.offer.expiresAt);
        _expiryController.text = DateFormat('yyyy-MM-dd').format(_selectedExpiry!);
      }
    }
  }

  Future<void> _selectExpiry(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiry ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
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

    final data = {
      'title': _titleController.text.trim(),
      'offerPercentage': double.tryParse(_discountController.text) ?? 0.0,
      'expires_at': _selectedExpiry != null ? DateFormat('yyyy-MM-dd').format(_selectedExpiry!) : null,
      'status': _status ? 1 : 0,
      'image': isEdit ? widget.offer.image : null,
    };

    bool success;
    if (isEdit) {
      success = await service.updateOffer(widget.offer.id, data);
    } else {
      success = await service.createOffer(data);
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
                validator: (v) => v!.isEmpty ? 'Discount is required' : null,
              ),
              20.toHeight,
              _buildExpiryPicker(),
              24.toHeight,
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
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEdit ? 'Update Offer' : 'Create Offer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
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
