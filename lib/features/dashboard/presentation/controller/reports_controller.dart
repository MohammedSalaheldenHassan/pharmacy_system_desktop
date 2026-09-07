import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/constant/roles.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/employees_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/profit_loss_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/settings_controller.dart';

enum ReportType { sales, inventory, expiring, employeePerformance }

extension ReportTypeLabel on ReportType {
  String get label {
    switch (this) {
      case ReportType.sales:
        return 'تقرير المبيعات';
      case ReportType.inventory:
        return 'تقرير المخزون';
      case ReportType.expiring:
        return 'تقرير المنتجات منتهية الصلاحية';
      case ReportType.employeePerformance:
        return 'تقرير أداء الموظفين';
    }
  }
}

/// A generic report row: column header -> cell value. Kept generic (rather
/// than one typed class per report) so a single sortable table widget can
/// render any of the four report types.
class ReportRow {
  final Map<String, dynamic> values;
  const ReportRow(this.values);
}

class ReportsController extends GetxController {
  static const String allLabel = 'الكل';

  final Rx<ReportType> selectedReport = ReportType.sales.obs;
  final Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);
  final RxString categoryFilter = allLabel.obs;
  final RxString employeeFilter = allLabel.obs;

  final RxString sortColumn = ''.obs;
  final RxBool sortAscending = true.obs;

  ProductsController get _products => Get.isRegistered<ProductsController>()
      ? Get.find<ProductsController>()
      : Get.put(ProductsController());

  ProfitLossController get _profitLoss => Get.isRegistered<ProfitLossController>()
      ? Get.find<ProfitLossController>()
      : Get.put(ProfitLossController());

  SettingsController get _settings => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController());

  EmployeesController get _employees => Get.isRegistered<EmployeesController>()
      ? Get.find<EmployeesController>()
      : Get.put(EmployeesController());

  List<String> get categoryOptions => [
        allLabel,
        ..._products.products.map((p) => p.category).toSet(),
      ];

  List<String> get employeeOptions => [
        allLabel,
        ..._employees.employees.where((e) => e.role == cashierRole).map((e) => e.name),
      ];

  void selectReport(ReportType type) {
    selectedReport.value = type;
    sortColumn.value = '';
    sortAscending.value = true;
  }

  void setDateRange(DateTimeRange range) => dateRange.value = range;

  void selectCategory(String category) => categoryFilter.value = category;

  void selectEmployee(String employee) => employeeFilter.value = employee;

  void toggleSort(String column) {
    if (sortColumn.value == column) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
  }

  List<String> get columns {
    switch (selectedReport.value) {
      case ReportType.sales:
        return const ['التاريخ', 'رقم الفاتورة', 'الكاشير', 'عدد الأصناف', 'الإجمالي'];
      case ReportType.inventory:
        return const ['المنتج', 'الفئة', 'الكمية', 'الحالة'];
      case ReportType.expiring:
        return const ['المنتج', 'تاريخ الانتهاء', 'الأيام المتبقية', 'الكمية'];
      case ReportType.employeePerformance:
        return const ['الموظف', 'عدد الفواتير', 'إجمالي المبيعات', 'إجمالي الربح'];
    }
  }

  /// Which filter controls are relevant for the current report — the UI
  /// only shows these.
  bool get usesDateRange =>
      selectedReport.value == ReportType.sales || selectedReport.value == ReportType.employeePerformance;

  bool get usesCategory =>
      selectedReport.value == ReportType.inventory || selectedReport.value == ReportType.expiring;

  bool get usesEmployee => selectedReport.value == ReportType.employeePerformance;

  List<ReportRow> _buildRows() {
    switch (selectedReport.value) {
      case ReportType.sales:
        final range = dateRange.value;
        return _profitLoss.sales
            .where((s) => range == null || (!s.date.isBefore(range.start) && s.date.isBefore(range.end.add(const Duration(days: 1)))))
            .map((s) => ReportRow({
                  'التاريخ': s.date,
                  'رقم الفاتورة': s.id,
                  'الكاشير': s.cashierName,
                  'عدد الأصناف': s.items.length,
                  'الإجمالي': s.totalRevenue,
                }))
            .toList();

      case ReportType.inventory:
        final threshold = _products.lowStockThreshold;
        return _products.products
            .where((p) => categoryFilter.value == allLabel || p.category == categoryFilter.value)
            .map((p) => ReportRow({
                  'المنتج': p.name,
                  'الفئة': p.category,
                  'الكمية': p.stock,
                  'الحالة': p.statusFor(threshold).label,
                }))
            .toList();

      case ReportType.expiring:
        final leadDays = _settings.settings.value.expiryAlertLeadDays;
        return _products.products
            .where((p) => categoryFilter.value == allLabel || p.category == categoryFilter.value)
            .where((p) => p.expiryDate.difference(DateTime.now()).inDays <= leadDays)
            .map((p) => ReportRow({
                  'المنتج': p.name,
                  'تاريخ الانتهاء': p.expiryDate,
                  'الأيام المتبقية': p.expiryDate.difference(DateTime.now()).inDays,
                  'الكمية': p.stock,
                }))
            .toList();

      case ReportType.employeePerformance:
        final range = dateRange.value;
        final sales = _profitLoss.sales.where(
          (s) => range == null || (!s.date.isBefore(range.start) && s.date.isBefore(range.end.add(const Duration(days: 1)))),
        );
        final Map<String, List<dynamic>> byCashier = {};
        for (final sale in sales) {
          if (employeeFilter.value != allLabel && sale.cashierName != employeeFilter.value) continue;
          byCashier.putIfAbsent(sale.cashierName, () => []).add(sale);
        }
        return byCashier.entries.map((entry) {
          final sales = entry.value.cast();
          final totalRevenue = sales.fold(0.0, (sum, s) => sum + s.totalRevenue);
          final totalProfit = sales.fold(0.0, (sum, s) => sum + s.totalProfit);
          return ReportRow({
            'الموظف': entry.key,
            'عدد الفواتير': sales.length,
            'إجمالي المبيعات': totalRevenue,
            'إجمالي الربح': totalProfit,
          });
        }).toList();
    }
  }

  List<ReportRow> get rows {
    final built = _buildRows();
    final col = sortColumn.value.isEmpty ? columns.first : sortColumn.value;
    final sorted = [...built];
    sorted.sort((a, b) {
      final va = a.values[col];
      final vb = b.values[col];
      int cmp;
      if (va is Comparable && vb is Comparable) {
        cmp = va.compareTo(vb);
      } else {
        cmp = va.toString().compareTo(vb.toString());
      }
      return sortAscending.value ? cmp : -cmp;
    });
    return sorted;
  }
}
