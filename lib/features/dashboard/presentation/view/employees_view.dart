import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/employees_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/employee_form_dialog.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/employees.dart';

class EmployeesView extends StatelessWidget {
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeesController controller = Get.put(EmployeesController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "إدارة الموظفين",
                      style: TextStyle(fontSize: 26, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "متابعة وإدارة بيانات موظفي الصيدلية",
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.dialog(const EmployeeFormDialog()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0e4a35),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                  label: const Text(
                    "إضافة موظف",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _StatsRow(controller: controller),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 800;
                final search = _SearchField(controller: controller);
                final filters = _Filters(controller: controller);
                if (isNarrow) {
                  return Column(children: [search, const SizedBox(height: 12), filters]);
                }
                return Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: 16),
                    filters,
                  ],
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xffF3F6FB),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 2, child: Center(child: _HeaderText("الموظف"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("الدور"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("الهاتف / البريد"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("تاريخ الالتحاق"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("الحالة"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("إجراءات"))),
                          ],
                        ),
                      ),
                      const Expanded(child: Employees()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller});
  final EmployeesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.people_alt_outlined,
              label: 'إجمالي الموظفين',
              value: '${controller.employees.length}',
              color: const Color(0xff0e4a35),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              label: 'الموظفون النشطون',
              value: '${controller.activeCount}',
              color: const Color(0xff2E7D32),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatCard(
              icon: Icons.pause_circle_outline,
              label: 'غير نشطين',
              value: '${controller.inactiveCount}',
              color: const Color(0xff9E1B1B),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});
  final EmployeesController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextFormField(
        onChanged: controller.updateSearchQuery,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
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
          hintText: "ابحث عن موظف (الاسم، البريد، الهاتف، الرقم الوظيفي)",
          hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});
  final EmployeesController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => _FilterDropdown(
            value: controller.selectedRole.value,
            items: controller.roles,
            onChanged: controller.selectRole,
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => _FilterDropdown(
            value: controller.selectedStatus.value,
            items: controller.statusOptions,
            onChanged: controller.selectStatus,
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({required this.value, required this.items, required this.onChanged});

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.black87, fontSize: 13),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }
}
