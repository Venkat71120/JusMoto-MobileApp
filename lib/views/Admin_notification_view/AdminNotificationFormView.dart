import 'package:car_service/customizations/colors.dart';
import 'package:car_service/services/admin_services/AdminNotificationService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminNotificationFormView extends StatefulWidget {
  const AdminNotificationFormView({super.key});

  @override
  State<AdminNotificationFormView> createState() => _AdminNotificationFormViewState();
}

class _AdminNotificationFormViewState extends State<AdminNotificationFormView> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _targetAudience = 'all'; // 'all', 'user', 'staff'
  bool _isLoading = false;

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final service = Provider.of<AdminNotificationService>(context, listen: false);

    final data = {
      'subject': _subjectController.text.trim(),
      'message': _messageController.text.trim(),
      'audience': _targetAudience,
    };

    final success = await service.sendBroadcastNotification(data);

    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Send Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text('Target Audience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildAudienceSelector(),
              const SizedBox(height: 32),
              const Text('Message Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _subjectController,
                label: 'Subject / Title',
                hint: 'e.g. Weekend Special Offer!',
                validator: (v) => v!.isEmpty ? 'Subject is required' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _messageController,
                label: 'Broadcast Message',
                hint: 'Enter the notification details here...',
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'Message is required' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Send Notification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'This notification will be sent immediately to the selected audience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudienceSelector() {
    return Row(
      children: [
        _audienceChip('All', 'all', Icons.groups),
        const SizedBox(width: 8),
        _audienceChip('Users', 'user', Icons.person),
        const SizedBox(width: 8),
        _audienceChip('Staff', 'staff', Icons.engineering),
      ],
    );
  }

  Widget _audienceChip(String label, String value, IconData icon) {
    bool isSelected = _targetAudience == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _targetAudience = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? primaryColor : Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? primaryColor : Colors.grey[400]),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? primaryColor : Colors.grey[600], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
