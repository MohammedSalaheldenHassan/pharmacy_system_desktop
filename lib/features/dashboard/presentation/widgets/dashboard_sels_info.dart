import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/dashboard_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/product_form_dialog.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/supplier_form_dialog.dart';
import 'package:pharmacy_system/features/pos/presentation/view/pos_view.dart';

const Color _brandColor = Color(0xff0e4a35);

class DashboardSelsInfo extends StatelessWidget {
  const DashboardSelsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _SalesTrendCard()),
        const SizedBox(height: 20),
        Expanded(child: _QuickActionsCard()),
      ],
    );
  }
}

class _SalesTrendCard extends StatelessWidget {
  const _SalesTrendCard();

  String _weekdayLabel(DateTime d) {
    const labels = ['اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];
    return labels[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 16, 18, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 10, bottom: 8),
            child: Text('المبيعات خلال آخر 7 أيام', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Obx(() {
              final points = controller.last7DaysSales;
              final maxY = points.map((p) => p.revenue).fold<double>(0, (a, b) => a > b ? a : b);
              return BarChart(
                BarChartData(
                  maxY: maxY == 0 ? 10 : maxY * 1.2,
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_weekdayLabel(points[index].day), style: const TextStyle(fontFamily: 'Cairo', fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < points.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(toY: points[i].revenue, color: _brandColor, width: 18, borderRadius: BorderRadius.circular(4)),
                        ],
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('إجراءات سريعة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.point_of_sale_outlined,
                    label: 'بيع جديد',
                    onTap: () => Get.to(() => const PosView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_box_outlined,
                    label: 'إضافة منتج',
                    onTap: () => Get.dialog(const ProductFormDialog()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_business_outlined,
                    label: 'إضافة مورد',
                    onTap: () => Get.dialog(const SupplierFormDialog()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _brandColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _brandColor, size: 26),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontFamily: 'Cairo', color: _brandColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
