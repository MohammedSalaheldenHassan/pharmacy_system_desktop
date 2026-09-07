import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/sale_record_model.dart';
import 'package:pharmacy_system/data/repositories/sale_repository.dart';

enum PeriodFilter { today, thisWeek, thisMonth, custom }

extension PeriodFilterLabel on PeriodFilter {
  String get label {
    switch (this) {
      case PeriodFilter.today:
        return 'اليوم';
      case PeriodFilter.thisWeek:
        return 'هذا الأسبوع';
      case PeriodFilter.thisMonth:
        return 'هذا الشهر';
      case PeriodFilter.custom:
        return 'نطاق مخصص';
    }
  }
}

class ProductProfitSummary {
  final String productName;
  final int quantitySold;
  final double revenue;
  final double cost;
  final double profit;

  const ProductProfitSummary({
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.cost,
    required this.profit,
  });
}

class DailyProfitPoint {
  final DateTime day;
  final double profit;

  const DailyProfitPoint({required this.day, required this.profit});
}

class ProfitLossController extends GetxController {
  final SaleRepository _repository = Get.find<SaleRepository>();

  /// In-memory mirror of `sales`/`sale_items` — the single shared ledger
  /// also read by Sales, Reports, and Dashboard, and appended to live by
  /// POS's `completeSale()`.
  final RxList<SaleRecordModel> sales = <SaleRecordModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    sales.assignAll(await _repository.getAll());
  }

  final Rx<PeriodFilter> period = PeriodFilter.thisMonth.obs;
  final Rx<DateTimeRange?> customRange = Rx<DateTimeRange?>(null);

  DateTimeRange get _effectiveRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (period.value) {
      case PeriodFilter.today:
        return DateTimeRange(start: today, end: today.add(const Duration(days: 1)));
      case PeriodFilter.thisWeek:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(start: start, end: today.add(const Duration(days: 1)));
      case PeriodFilter.thisMonth:
        final start = DateTime(today.year, today.month, 1);
        return DateTimeRange(start: start, end: today.add(const Duration(days: 1)));
      case PeriodFilter.custom:
        return customRange.value ??
            DateTimeRange(start: today.subtract(const Duration(days: 30)), end: today.add(const Duration(days: 1)));
    }
  }

  void selectPeriod(PeriodFilter value) => period.value = value;

  void setCustomRange(DateTimeRange range) {
    customRange.value = range;
    period.value = PeriodFilter.custom;
  }

  List<SaleRecordModel> get filteredSales {
    final range = _effectiveRange;
    return sales.where((s) => !s.date.isBefore(range.start) && s.date.isBefore(range.end)).toList();
  }

  double get totalRevenue => filteredSales.fold(0.0, (sum, s) => sum + s.totalRevenue);

  double get totalCost => filteredSales.fold(0.0, (sum, s) => sum + s.totalCost);

  double get netProfit => totalRevenue - totalCost;

  double get profitMarginPercent => totalRevenue == 0 ? 0 : (netProfit / totalRevenue) * 100;

  /// Daily profit trend across the selected period, for the chart.
  List<DailyProfitPoint> get dailyProfitTrend {
    final Map<DateTime, double> byDay = {};
    for (final sale in filteredSales) {
      final day = DateTime(sale.date.year, sale.date.month, sale.date.day);
      byDay[day] = (byDay[day] ?? 0) + sale.totalProfit;
    }
    final days = byDay.keys.toList()..sort();
    return days.map((d) => DailyProfitPoint(day: d, profit: byDay[d]!)).toList();
  }

  /// Per-product breakdown across the selected period, for the table.
  List<ProductProfitSummary> get productBreakdown {
    final Map<String, List<SaleRecordItem>> byProduct = {};
    for (final sale in filteredSales) {
      for (final item in sale.items) {
        byProduct.putIfAbsent(item.productName, () => []).add(item);
      }
    }
    final summaries = byProduct.entries.map((entry) {
      final items = entry.value;
      return ProductProfitSummary(
        productName: entry.key,
        quantitySold: items.fold(0, (sum, i) => sum + i.quantity),
        revenue: items.fold(0.0, (sum, i) => sum + i.revenue),
        cost: items.fold(0.0, (sum, i) => sum + i.cost),
        profit: items.fold(0.0, (sum, i) => sum + i.profit),
      );
    }).toList();
    summaries.sort((a, b) => b.profit.compareTo(a.profit));
    return summaries;
  }
}
