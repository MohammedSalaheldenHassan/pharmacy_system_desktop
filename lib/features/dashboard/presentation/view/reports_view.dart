import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/reports_controller.dart';

const Color _brandColor = Color(0xff0e4a35);

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportsController controller = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "التقارير",
              style: TextStyle(fontSize: 26, fontFamily: "Cairo", fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "اختر تقريراً جاهزاً وحدد الفلاتر لعرض النتائج",
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _ReportTypeSelector(controller: controller),
            const SizedBox(height: 16),
            _FiltersBar(controller: controller),
            const SizedBox(height: 16),
            Expanded(child: _ReportTable(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _ReportTypeSelector extends StatelessWidget {
  const _ReportTypeSelector({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final type in ReportType.values)
            ChoiceChip(
              label: Text(type.label, style: const TextStyle(fontFamily: 'Cairo')),
              selected: controller.selectedReport.value == type,
              onSelected: (_) => controller.selectReport(type),
              selectedColor: _brandColor,
              labelStyle: TextStyle(
                fontFamily: 'Cairo',
                color: controller.selectedReport.value == type ? Colors.white : Colors.black87,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
        ],
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({required this.controller});
  final ReportsController controller;

  Future<void> _pickDateRange(BuildContext context) async {
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
    // A Wrap can't contain a Spacer/Expanded (those only work inside a
    // Flex), so the wrapping filters and the export button are two
    // separate children of an outer Row instead — the filters group still
    // wraps to a new line on a narrow window, and the button stays
    // pinned to the end whenever there's room.
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (controller.usesDateRange)
                  OutlinedButton.icon(
                    onPressed: () => _pickDateRange(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.date_range_outlined, size: 18, color: _brandColor),
                    label: Text(
                      controller.dateRange.value == null
                          ? 'كل الفترات'
                          : '${_fmt(controller.dateRange.value!.start)} - ${_fmt(controller.dateRange.value!.end)}',
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                if (controller.usesCategory)
                  _Dropdown(
                    value: controller.categoryFilter.value,
                    items: controller.categoryOptions,
                    onChanged: controller.selectCategory,
                  ),
                if (controller.usesEmployee)
                  _Dropdown(
                    value: controller.employeeFilter.value,
                    items: controller.employeeOptions,
                    onChanged: controller.selectEmployee,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            // TODO: export real PDF/Excel when backend is ready.
            onPressed: () => Get.snackbar(
              'غير متاح بعد',
              'سيتم تفعيل التصدير عند ربط قاعدة البيانات',
              backgroundColor: Colors.grey.shade800,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _brandColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.file_download_outlined, size: 18, color: _brandColor),
            label: const Text('تصدير', style: TextStyle(fontFamily: 'Cairo', color: _brandColor)),
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.value, required this.items, required this.onChanged});

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
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

class _ReportTable extends StatelessWidget {
  const _ReportTable({required this.controller});
  final ReportsController controller;

  String _displayValue(dynamic value) {
    if (value is double) return '${value.toStringAsFixed(2)} ج.س';
    if (value is DateTime) {
      return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Obx(() {
        final columns = controller.columns;
        final rows = controller.rows;
        final activeSortColumn = controller.sortColumn.value.isEmpty ? columns.first : controller.sortColumn.value;

        return Column(
          children: [
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xffF3F6FB),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final column in columns)
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.toggleSort(column),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                column,
                                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13),
                              ),
                              if (activeSortColumn == column) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  controller.sortAscending.value ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 14,
                                  color: _brandColor,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: rows.isEmpty
                  ? Center(
                      child: Text('لا توجد بيانات مطابقة', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade500)),
                    )
                  : ListView.separated(
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
                              for (final column in columns)
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      _displayValue(row.values[column]),
                                      style: const TextStyle(fontFamily: 'Cairo'),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
