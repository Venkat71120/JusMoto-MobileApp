import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/admin_services/AdminVehicleService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminVariantFormView extends StatefulWidget {
  final dynamic variant;
  const AdminVariantFormView({super.key, this.variant});

  @override
  State<AdminVariantFormView> createState() => _AdminVariantFormViewState();
}

class _AdminVariantFormViewState extends State<AdminVariantFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  int? _selectedCarId;
  bool _isLoading = false;

  bool get isEdit => widget.variant != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<AdminVehicleService>(context, listen: false).fetchCars(page: 1);
    });

    if (isEdit) {
      _nameController.text = widget.variant.name;
      _selectedCarId = widget.variant.carId;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedCarId == null) {
      if (_selectedCarId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a car model')));
      }
      return;
    }

    setState(() => _isLoading = true);
    final service = Provider.of<AdminVehicleService>(context, listen: false);

    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'car_id': _selectedCarId,
      'status': '1',
    };

    bool success;
    if (isEdit) {
      success = await service.updateVariant(widget.variant.id, data);
    } else {
      success = await service.createVariant(data);
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
        title: Text(isEdit ? 'Edit Variant' : 'Add Variant', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              _buildCarDropdown(),
              20.toHeight,
              _buildTextField(
                controller: _nameController,
                label: 'Variant Name',
                hint: 'e.g. VXI, LXI, Top Model',
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
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
                      : Text(isEdit ? 'Update Variant' : 'Create Variant', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Car Model', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                  value: _selectedCarId,
                  hint: const Text('Select Car Model'),
                  isExpanded: true,
                  items: service.carList.cars.map((car) {
                    return DropdownMenuItem<int>(
                      value: car.id,
                      child: Text('${car.brand?.name ?? ""} ${car.name}'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCarId = val),
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        8.toHeight,
        TextFormField(
          controller: controller,
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
    super.dispose();
  }
}
