import 'package:car_service/customizations/colors.dart';
import 'package:car_service/models/admin_models/AdminUserModels.dart';
import 'package:car_service/services/admin_services/AdminOutletService.dart';
import 'package:car_service/services/admin_services/AdminUserManagementService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminUserEditFormView extends StatefulWidget {
  final AdminBaseUserItem? user;
  final String type;

  const AdminUserEditFormView({super.key, this.user, required this.type});

  @override
  State<AdminUserEditFormView> createState() => _AdminUserEditFormViewState();
}

class _AdminUserEditFormViewState extends State<AdminUserEditFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  int? _selectedOutletId;
  String? _selectedRole;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name);
    _emailController = TextEditingController(text: widget.user?.email);
    _phoneController = TextEditingController(text: widget.user?.phone);
    _usernameController = TextEditingController(text: widget.user?.username);
    _passwordController = TextEditingController();

    _selectedOutletId = widget.user?.outletId;
    _selectedRole = widget.user?.role;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminUserManagementService>(context, listen: false).fetchRoles();
      Provider.of<AdminOutletService>(context, listen: false).fetchOutlets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit ${widget.type.toUpperCase()}' : 'Add New ${widget.type.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              Text(isEdit ? 'Update Details' : 'Account Details', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(isEdit ? 'Modify account information below. Leave password blank to keep current.' : 'Fill in the details below to create a new account.', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              
              _buildLabel('Full Name'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Enter name', Icons.person_outline),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              if (widget.type == 'staff') ...[
                _buildLabel('Username'),
                TextFormField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Enter username', Icons.alternate_email),
                  validator: (v) => v!.isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 16),
              ],

              _buildLabel('Email Address'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('email@example.com', Icons.email_outlined),
                validator: (v) => v!.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),

              if (widget.type == 'franchise') ...[
                _buildLabel('Phone Number'),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('00000 00000', Icons.phone_outlined),
                ),
                const SizedBox(height: 16),
              ],

              if (widget.type == 'staff') ...[
                _buildLabel('Outlet Assignment (Optional)'),
                Consumer<AdminOutletService>(
                  builder: (context, outletService, _) {
                    return DropdownButtonFormField<int>(
                      value: _selectedOutletId,
                      items: outletService.outletList.outlets.map((o) => DropdownMenuItem(value: o.id, child: Text(o.name))).toList(),
                      onChanged: (val) => setState(() => _selectedOutletId = val),
                      decoration: _inputDecoration('Select Outlet', Icons.location_on_outlined),
                    );
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Role'),
                Consumer<AdminUserManagementService>(
                  builder: (context, userService, _) {
                    return DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: userService.roles.map((r) => DropdownMenuItem(value: r['name'].toString(), child: Text(r['name'].toString()))).toList(),
                      onChanged: (val) => setState(() => _selectedRole = val),
                      decoration: _inputDecoration('Select Role', Icons.security_outlined),
                      validator: (v) => v == null ? 'Role is required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              _buildLabel(isEdit ? 'New Password (Optional)' : 'Account Password'),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration(isEdit ? 'Leave blank to keep current' : 'Enter password', Icons.lock_outline),
                validator: (v) => !isEdit && v!.isEmpty ? 'Password is required for new accounts' : null,
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
                  child: Text(isEdit ? 'Update Account' : 'Create Account', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
      };

      if (widget.type == 'staff') {
        data['username'] = _usernameController.text;
        data['role'] = _selectedRole;
        if (_selectedOutletId != null) data['outlet_location_id'] = _selectedOutletId;
      } else if (widget.type == 'franchise') {
        data['mobile_number'] = _phoneController.text;
      }

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      final service = Provider.of<AdminUserManagementService>(context, listen: false);
      
      bool success;
      if (isEdit) {
        success = await service.updateUserDetail(widget.user!.id, widget.type, data);
      } else {
        if (widget.type == 'staff') {
          success = await service.createStaff(data);
        } else if (widget.type == 'franchise') {
          success = await service.createFranchise(data);
        } else {
          success = await service.createUser(data);
        }
      }

      if (success && mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
