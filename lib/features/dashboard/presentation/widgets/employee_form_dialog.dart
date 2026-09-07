import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/constant/roles.dart';
import 'package:pharmacy_system/data/models/employee_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/employees_controller.dart';

/// Shared dialog for both adding a new employee and editing an existing one.
/// Pass [existing] to pre-fill the fields in edit mode.
class EmployeeFormDialog extends StatefulWidget {
  const EmployeeFormDialog({super.key, this.existing});

  final EmployeeModel? existing;

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late String _role;
  late DateTime _joinDate;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _username = TextEditingController(text: e?.username ?? '');
    _password = TextEditingController(text: e?.password ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _role = e?.role ?? adminRole;
    _joinDate = e?.joinDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _joinDate = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = Get.find<EmployeesController>();

    if (_isEditing) {
      controller.updateEmployee(
        widget.existing!.copyWith(
          name: _name.text.trim(),
          username: _username.text.trim(),
          password: _password.text,
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          role: _role,
          joinDate: _joinDate,
        ),
      );
    } else {
      controller.addEmployee(
        name: _name.text.trim(),
        username: _username.text.trim(),
        password: _password.text,
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        role: _role,
        joinDate: _joinDate,
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
                    _isEditing ? 'تعديل الموظف' : 'إضافة موظف جديد',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _name,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    validator: _required,
                    decoration: _decoration('الاسم الكامل'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _username,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          validator: _required,
                          decoration: _decoration('اسم المستخدم'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _password,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          validator: _isEditing ? null : _required,
                          decoration: _decoration(_isEditing ? 'كلمة المرور (اتركها فارغة لعدم التغيير)' : 'كلمة المرور'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    validator: _required,
                    decoration: _decoration('البريد الإلكتروني'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    validator: _required,
                    decoration: _decoration('رقم الهاتف'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87),
                    decoration: _decoration('الدور الوظيفي'),
                    items: employeeRoles
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _role = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickJoinDate,
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: _decoration('تاريخ الالتحاق'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_joinDate.year}-${_joinDate.month.toString().padLeft(2, '0')}-${_joinDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
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
