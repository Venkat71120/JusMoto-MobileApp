import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminFranchiseService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminFranchiseFormView extends StatefulWidget {
  final dynamic franchise; // Pass the franchise object for editing
  const AdminFranchiseFormView({super.key, this.franchise});

  @override
  State<AdminFranchiseFormView> createState() => _AdminFranchiseFormViewState();
}

class _AdminFranchiseFormViewState extends State<AdminFranchiseFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  bool get isEdit => widget.franchise != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.franchise.name;
      _emailController.text = widget.franchise.email;
      // Password is not shown for editing
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final service = Provider.of<AdminFranchiseService>(context, listen: false);

    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    if (!isEdit) {
      data['password'] = _passwordController.text.trim();
    }

    bool success;
    if (isEdit) {
      success = await service.updateFranchise(widget.franchise.id, data);
    } else {
      success = await service.createFranchise(data);
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
        title: Text(isEdit ? 'Edit Franchise Partner' : 'Add Franchise Partner', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                label: 'Franchise Name',
                hint: 'Enter franchise partner name',
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              20.toHeight,
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email is required' : null,
              ),
              20.toHeight,
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '10-digit mobile number',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length != 10) return 'Phone must be 10 digits';
                  return null;
                },
              ),
              if (!isEdit) ...[
                20.toHeight,
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Set partner password',
                  obscureText: true,
                  validator: (v) => v!.isEmpty || v.length < 6 ? 'Password (min 6 chars) is required' : null,
                ),
              ],
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
                      : Text(isEdit ? 'Update Partner' : 'Create Partner', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
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
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        8.toHeight,
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
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
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
