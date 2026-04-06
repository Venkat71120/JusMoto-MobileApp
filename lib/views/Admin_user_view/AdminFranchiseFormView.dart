import 'package:car_service/customizations/colors.dart';
import 'package:car_service/view_models/admin_view_models/AdminUserManagementViewModel.dart';
import 'package:flutter/material.dart';

class AdminFranchiseFormView extends StatefulWidget {
  const AdminFranchiseFormView({super.key});

  @override
  State<AdminFranchiseFormView> createState() => _AdminFranchiseFormViewState();
}

class _AdminFranchiseFormViewState extends State<AdminFranchiseFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AdminUserManagementViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminUserManagementViewModel(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Franchise Partner', style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text('Partner Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Enter the information below to create a new franchise account.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              
              _buildLabel('Full Name'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Enter partner name', Icons.person_outline),
                validator: (v) => v!.isEmpty ? 'First name/Full name is required' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Email Address'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('partner@example.com', Icons.email_outlined),
                validator: (v) => v!.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Phone Number'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('00000 00000', Icons.phone_outlined),
                validator: (v) => v!.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Account Password'),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration('Set initial password', Icons.lock_outline),
                validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _submit(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
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
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor)),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'email': _emailController.text,
        'mobile_number': _phoneController.text,
        'password': _passwordController.text,
      };

      await _viewModel.createFranchise(data);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
