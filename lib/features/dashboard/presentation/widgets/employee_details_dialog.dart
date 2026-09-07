import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/employee_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/employee_status_badge.dart';

class EmployeeDetailsDialog extends StatelessWidget {
  const EmployeeDetailsDialog({super.key, required this.employee});

  final EmployeeModel employee;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      employee.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                  ),
                  EmployeeStatusBadge(status: employee.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                employee.role,
                style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 13),
              ),
              const Divider(height: 28),
              _DetailRow(label: 'الرقم الوظيفي', value: employee.id),
              _DetailRow(label: 'اسم المستخدم', value: employee.username),
              _DetailRow(label: 'البريد الإلكتروني', value: employee.email),
              _DetailRow(label: 'رقم الهاتف', value: employee.phone),
              _DetailRow(
                label: 'تاريخ الالتحاق',
                value:
                    '${employee.joinDate.year}-${employee.joinDate.month.toString().padLeft(2, '0')}-${employee.joinDate.day.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0e4a35),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('إغلاق', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
