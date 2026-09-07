import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/supplier_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/suppliers_controller.dart';

/// Shared dialog for both adding a new supplier and editing an existing one.
/// Pass [existing] to pre-fill the fields in edit mode.
class SupplierFormDialog extends StatefulWidget {
  const SupplierFormDialog({super.key, this.existing});

  final SupplierModel? existing;

  @override
  State<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _contactPerson;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _name = TextEditingController(text: s?.name ?? '');
    _contactPerson = TextEditingController(text: s?.contactPerson ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _email = TextEditingController(text: s?.email ?? '');
    _address = TextEditingController(text: s?.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _contactPerson.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = Get.find<SuppliersController>();

    if (_isEditing) {
      controller.updateSupplier(
        widget.existing!.copyWith(
          name: _name.text.trim(),
          contactPerson: _contactPerson.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          address: _address.text.trim(),
        ),
      );
    } else {
      controller.addSupplier(
        name: _name.text.trim(),
        contactPerson: _contactPerson.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
      );
    }
    Get.back();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xff0e4a35)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isEditing ? 'تعديل المورد' : 'إضافة مورد جديد',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _name,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    validator: _required,
                    decoration: _decoration('اسم المورد'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactPerson,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    validator: _required,
                    decoration: _decoration('الشخص المسؤول'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phone,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          validator: _required,
                          decoration: _decoration('رقم الهاتف'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _email,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          validator: _required,
                          decoration: _decoration('البريد الإلكتروني'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    validator: _required,
                    decoration: _decoration('العنوان'),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0e4a35),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            _isEditing ? 'حفظ التعديلات' : 'إضافة',
                            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
