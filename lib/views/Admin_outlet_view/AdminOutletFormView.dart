import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminOutletService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminOutletFormView extends StatefulWidget {
  final dynamic outlet;
  const AdminOutletFormView({super.key, this.outlet});

  @override
  State<AdminOutletFormView> createState() => _AdminOutletFormViewState();
}

class _AdminOutletFormViewState extends State<AdminOutletFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  
  bool _status = true;
  bool _isLoading = false;

  bool get isEdit => widget.outlet != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.outlet.name;
      _addressController.text = widget.outlet.address;
      _postCodeController.text = widget.outlet.postCode ?? '';
      _latController.text = widget.outlet.latitude ?? '';
      _lngController.text = widget.outlet.longitude ?? '';
      _status = widget.outlet.status == 1;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final service = Provider.of<AdminOutletService>(context, listen: false);

    final data = {
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'post_code': _postCodeController.text.trim(),
      'latitude': _latController.text.trim(),
      'longitude': _lngController.text.trim(),
      'status': _status ? 1 : 0,
    };

    bool success;
    if (isEdit) {
      success = await service.updateOutlet(widget.outlet.id, data);
    } else {
      success = await service.createOutlet(data);
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
        title: Text(isEdit ? 'Edit Outlet' : 'Add Outlet', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                controller: _nameController,
                label: 'Outlet Name',
                hint: 'e.g. Downtown Service Center',
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              20.toHeight,
              _buildTextField(
                controller: _addressController,
                label: 'Full Address',
                hint: 'e.g. 123 Main St, Area, City',
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Address is required' : null,
              ),
              20.toHeight,
              _buildTextField(
                controller: _postCodeController,
                label: 'Post Code (Optional)',
                hint: 'e.g. 560001',
              ),
              20.toHeight,
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latController,
                      label: 'Latitude',
                      hint: '0.000000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  16.toWidth,
                  Expanded(
                    child: _buildTextField(
                      controller: _lngController,
                      label: 'Longitude',
                      hint: '0.000000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
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
                      : Text(isEdit ? 'Update Outlet' : 'Create Outlet', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
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
          maxLines: maxLines,
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
    _addressController.dispose();
    _postCodeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}
