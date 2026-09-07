import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/dashboard_controller.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(
      () => Row(
        spacing: 10,
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.point_of_sale_outlined,
              label: 'مبيعات اليوم',
              value: '${controller.todaysSales.toStringAsFixed(0)} ج.س',
              color: const Color(0xff0e4a35),
            ),
          ),
          Expanded(
            child: _StatCard(
              icon: Icons.inventory_2_outlined,
              label: 'منتجات منخفضة المخزون',
              value: '${controller.lowStockCount}',
              color: const Color(0xffB8860B),
            ),
          ),
          Expanded(
            child: _StatCard(
              icon: Icons.warning_amber_outlined,
              label: 'تنبيهات الصلاحية',
              value: '${controller.expiryAlertsCount}',
              color: const Color(0xff9E1B1B),
            ),
          ),
          Expanded(
            child: _StatCard(
              icon: Icons.badge_outlined,
              label: 'الموظفون النشطون',
              value: '${controller.activeEmployeesCount}',
              color: const Color(0xff1565C0),
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
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
