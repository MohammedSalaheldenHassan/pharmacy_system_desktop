import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/profit_loss_controller.dart';

const Color _brandColor = Color(0xff0e4a35);

class ProfitsLossView extends StatelessWidget {
  const ProfitsLossView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfitLossController controller = Get.put(ProfitLossController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "الأرباح والخسائر",
              style: TextStyle(fontSize: 26, fontFamily: "Cairo", fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "ملخص الأداء المالي حسب الفترة المحددة",
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _PeriodFilterBar(controller: controller),
            const SizedBox(height: 20),
            _SummaryCards(controller: controller),
            const SizedBox(height: 20),
            _TrendChartCard(controller: controller),
            const SizedBox(height: 20),
            _ProductBreakdownTable(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _PeriodFilterBar extends StatelessWidget {
  const _PeriodFilterBar({required this.controller});
  final ProfitLossController controller;

  Future<void> _pickCustomRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: controller.customRange.value,
    );
    if (range != null) controller.setCustomRange(range);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final option in [PeriodFilter.today, PeriodFilter.thisWeek, PeriodFilter.thisMonth])
            ChoiceChip(
              label: Text(option.label, style: const TextStyle(fontFamily: 'Cairo')),
              selected: controller.period.value == option,
              onSelected: (_) => controller.selectPeriod(option),
              selectedColor: _brandColor,
              labelStyle: TextStyle(
                fontFamily: 'Cairo',
                color: controller.period.value == option ? Colors.white : Colors.black87,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => _pickCustomRange(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: controller.period.value == PeriodFilter.custom ? _brandColor.withValues(alpha: 0.08) : Colors.white,
              side: BorderSide(color: controller.period.value == PeriodFilter.custom ? _brandColor : Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            icon: const Icon(Icons.date_range_outlined, size: 18, color: _brandColor),
            label: Text(
              controller.customRange.value == null
                  ? 'نطاق مخصص'
                  : '${_fmt(controller.customRange.value!.start)} - ${_fmt(controller.customRange.value!.end)}',
              style: const TextStyle(fontFamily: 'Cairo', color: _brandColor),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.controller});
  final ProfitLossController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.point_of_sale_outlined,
              label: 'إجمالي المبيعات',
              value: '${controller.totalRevenue.toStringAsFixed(0)} ج.س',
              color: _brandColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatCard(
              icon: Icons.inventory_outlined,
              label: 'إجمالي التكلفة',
              value: '${controller.totalCost.toStringAsFixed(0)} ج.س',
              color: const Color(0xffB8860B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatCard(
              icon: Icons.trending_up_outlined,
              label: 'صافي الربح',
              value: '${controller.netProfit.toStringAsFixed(0)} ج.س',
              color: controller.netProfit >= 0 ? const Color(0xff2E7D32) : const Color(0xff9E1B1B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatCard(
              icon: Icons.percent_outlined,
              label: 'هامش الربح',
              value: '${controller.profitMarginPercent.toStringAsFixed(1)}%',
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({required this.controller});
  final ProfitLossController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(8, 18, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 10, bottom: 8),
            child: Text('اتجاه الربح اليومي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Obx(() {
              final points = controller.dailyProfitTrend;
              if (points.isEmpty) {
                return Center(
                  child: Text('لا توجد بيانات كافية لعرض الرسم البياني', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade500)),
                );
              }
              return LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].profit),
                      ],
                      isCurved: true,
                      color: _brandColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: _brandColor.withValues(alpha: 0.08)),
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

class _ProductBreakdownTable extends StatelessWidget {
  const _ProductBreakdownTable({required this.controller});
  final ProfitLossController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: Center(child: _HeaderText("المنتج"))),
                Expanded(flex: 1, child: Center(child: _HeaderText("الكمية المباعة"))),
                Expanded(flex: 2, child: Center(child: _HeaderText("الإيرادات"))),
                Expanded(flex: 2, child: Center(child: _HeaderText("التكلفة"))),
                Expanded(flex: 2, child: Center(child: _HeaderText("الربح"))),
              ],
            ),
          ),
          Obx(() {
            final rows = controller.productBreakdown;
            if (rows.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('لا توجد مبيعات خلال هذه الفترة', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade500)),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: rows.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final row = rows[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(flex: 3, child: Text(row.productName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600))),
                      Expanded(flex: 1, child: Center(child: Text('${row.quantitySold}', style: const TextStyle(fontFamily: 'Cairo')))),
                      Expanded(flex: 2, child: Center(child: Text('${row.revenue.toStringAsFixed(2)} ج.س', style: const TextStyle(fontFamily: 'Cairo')))),
                      Expanded(flex: 2, child: Center(child: Text('${row.cost.toStringAsFixed(2)} ج.س', style: const TextStyle(fontFamily: 'Cairo')))),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            '${row.profit.toStringAsFixed(2)} ج.س',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w600,
                              color: row.profit >= 0 ? const Color(0xff2E7D32) : const Color(0xff9E1B1B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
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
