import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/utils/arabic_plural.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/sales_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/sale_row.dart';
import 'package:pharmacy_system/features/pos/presentation/view/pos_view.dart';

const Color _brandColor = Color(0xff0e4a35);

class SelsView extends StatelessWidget {
  const SelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.put(SalesController());

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "المبيعات",
                      style: TextStyle(fontSize: 26, fontFamily: "Cairo", fontWeight: FontWeight.bold),
                    ),
                    Obx(
                      () => Text(
                        formatArabicCount(
                          controller.filteredSales.length,
                          zero: 'لا توجد فواتير',
                          singular: 'فاتورة واحدة',
                          dual: 'فاتورتان',
                          pluralFew: 'فواتير',
                          pluralMany: 'فاتورة',
                        ),
                        style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const PosView()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandColor,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.point_of_sale_outlined, color: Colors.white),
                  label: const Text("بيع جديد", style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Cairo')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SummaryRow(controller: controller),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 800;
                final search = _SearchField(controller: controller);
                final dateFilter = _DateRangeFilter(controller: controller);
                if (isNarrow) {
                  return Column(children: [search, const SizedBox(height: 12), dateFilter]);
                }
                return Row(children: [Expanded(child: search), const SizedBox(width: 16), dateFilter]);
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
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 2, child: Center(child: _HeaderText("رقم الفاتورة"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("التاريخ"))),
                            Expanded(flex: 2, child: Center(child: _HeaderText("الكاشير"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("عدد الأصناف"))),
                            Expanded(flex: 1, child: Center(child: _HeaderText("الإجمالي"))),
                          ],
                        ),
                      ),
                      const Expanded(child: SaleList()),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.controller});
  final SalesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.today_outlined,
              label: 'فواتير اليوم',
              value: '${controller.todaysSalesCount}',
              color: _brandColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatCard(
              icon: Icons.payments_outlined,
              label: 'إجمالي المبيعات (حسب الفلتر)',
              value: '${controller.totalRevenue.toStringAsFixed(0)} ج.س',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});
  final SalesController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextFormField(
        onChanged: controller.updateSearchQuery,
        style: const TextStyle(fontFamily: 'Cairo'),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _brandColor)),
          hintText: "ابحث برقم الفاتورة أو اسم الكاشير",
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

class _DateRangeFilter extends StatelessWidget {
  const _DateRangeFilter({required this.controller});
  final SalesController controller;

  Future<void> _pick(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: controller.dateRange.value,
    );
    if (range != null) controller.setDateRange(range);
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            onPressed: () => _pick(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            icon: const Icon(Icons.date_range_outlined, size: 18, color: _brandColor),
            label: Text(
              controller.dateRange.value == null
                  ? 'كل الفترات'
                  : '${_fmt(controller.dateRange.value!.start)} - ${_fmt(controller.dateRange.value!.end)}',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          if (controller.dateRange.value != null)
            IconButton(
              onPressed: () => controller.setDateRange(null),
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              tooltip: 'مسح الفلتر',
            ),
        ],
      ),
    );
  }
}
