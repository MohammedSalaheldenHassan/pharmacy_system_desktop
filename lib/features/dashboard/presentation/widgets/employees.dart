import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/employee_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/employees_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/employee_details_dialog.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/employee_form_dialog.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/employee_status_badge.dart';

class Employees extends StatelessWidget {
  const Employees({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeesController controller = Get.find<EmployeesController>();

    return Obx(() {
      final employees = controller.filteredEmployees;

      if (employees.isEmpty) {
        return const _EmptyEmployees();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) => _EmployeeRow(employee: employees[index]),
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
        itemCount: employees.length,
      );
    });
  }
}

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow({required this.employee});

  final EmployeeModel employee;

  String get _formattedJoinDate =>
      '${employee.joinDate.year}-${employee.joinDate.month.toString().padLeft(2, '0')}-${employee.joinDate.day.toString().padLeft(2, '0')}';

  void _showDetails() => Get.dialog(EmployeeDetailsDialog(employee: employee));

  void _showEditDialog() => Get.dialog(EmployeeFormDialog(existing: employee));

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('حذف الموظف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Text(
          'هل أنت متأكد من حذف "${employee.name}"؟ لا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Get.find<EmployeesController>().deleteEmployee(employee.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showDetails,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                  ),
                  Text(
                    employee.id,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: Center(child: Text(employee.role, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(employee.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  Text(
                    employee.phone,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: Center(child: Text(_formattedJoinDate, style: const TextStyle(fontFamily: 'Cairo')))),
            Expanded(
              flex: 1,
              child: Center(
                child: InkWell(
                  onTap: () => Get.find<EmployeesController>().toggleActive(employee),
                  child: EmployeeStatusBadge(status: employee.status),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _showEditDialog,
                    icon: const Icon(Icons.edit_outlined, color: Color(0xff0e4a35), size: 20),
                  ),
                  IconButton(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEmployees extends StatelessWidget {
  const _EmptyEmployees();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'لا يوجد موظفون مطابقون',
            style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'جرّب تعديل كلمة البحث أو الفلاتر',
            style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Cairo', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
