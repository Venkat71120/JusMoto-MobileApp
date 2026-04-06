import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminMarketingService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminCouponFormView extends StatefulWidget {
  final dynamic coupon;
  const AdminCouponFormView({super.key, this.coupon});

  @override
  State<AdminCouponFormView> createState() => _AdminCouponFormViewState();
}

class _AdminCouponFormViewState extends State<AdminCouponFormView> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _discountController = TextEditingController();
  final _expiryController = TextEditingController();
  
  String _discountType = 'percentage';
  bool _status = true;
  bool _isLoading = false;
  DateTime? _selectedExpiry;

  bool get isEdit => widget.coupon != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _codeController.text = widget.coupon.code;
      _titleController.text = widget.coupon.title ?? '';
      _discountController.text = widget.coupon.discount.toString();
      _discountType = widget.coupon.discountType;
      _status = widget.coupon.status == 1;
      
      if (widget.coupon.expireDate != null) {
        _selectedExpiry = DateTime.parse(widget.coupon.expireDate);
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
      'code': _codeController.text.trim().toUpperCase(),
      'title': _titleController.text.trim(),
      'discount': double.tryParse(_discountController.text) ?? 0.0,
      'discount_type': _discountType,
      'expire_date': _selectedExpiry != null ? DateFormat('yyyy-MM-dd').format(_selectedExpiry!) : null,
      'status': _status ? 1 : 0,
    };

    bool success;
    if (isEdit) {
      success = await service.updateCoupon(widget.coupon.id, data);
    } else {
      success = await service.createCoupon(data);
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
        title: Text(isEdit ? 'Edit Coupon' : 'Add Coupon', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                controller: _codeController,
                label: 'Coupon Code',
                hint: 'e.g. SUMMER2024',
                validator: (v) => v!.isEmpty ? 'Code is required' : null,
              ),
              20.toHeight,
              _buildTextField(
                controller: _titleController,
                label: 'Title / Description',
                hint: 'e.g. Save 20% on all car washes',
              ),
              20.toHeight,
              Row(
                children: [
                   Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _discountController,
                      label: 'Discount Value',
                      hint: '0.00',
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Value is required' : null,
                    ),
                  ),
                  16.toWidth,
                  Expanded(
                    flex: 3,
                    child: _buildTypeDropdown(),
                  ),
                ],
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
                      : Text(isEdit ? 'Update Coupon' : 'Create Coupon', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Discount Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        8.toHeight,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _discountType,
              isExpanded: true,
              items: const [
                DropdownMenuItem<String>(value: 'percentage', child: Text('Percentage (%)')),
                DropdownMenuItem<String>(value: 'fixed', child: Text('Fixed Amount (\u20B9)')),
              ],
              onChanged: (v) => setState(() => _discountType = v!),
            ),
          ),
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
    _codeController.dispose();
    _titleController.dispose();
    _discountController.dispose();
    _expiryController.dispose();
    super.dispose();
  }
}
