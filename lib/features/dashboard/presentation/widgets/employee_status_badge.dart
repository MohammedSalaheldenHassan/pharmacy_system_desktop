import 'package:flutter/material.dart';
import 'package:pharmacy_system/core/mock/models/employee_model.dart';

class EmployeeStatusBadge extends StatelessWidget {
  const EmployeeStatusBadge({super.key, required this.status});

  final EmployeeStatus status;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == EmployeeStatus.active;
    final Color color = isActive ? const Color(0xff2E7D32) : const Color(0xff9E1B1B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
