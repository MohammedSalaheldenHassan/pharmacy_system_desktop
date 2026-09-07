import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/sale_record_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/profit_loss_controller.dart';

/// Admin-facing sales/invoice history. Reads the same ledger as Profit &
/// Loss ([ProfitLossController.sales]) — no separate sales dataset — with
/// its own independent search/date filter state.
class SalesController extends GetxController {
  final RxString searchQuery = ''.obs;
  final Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);

  ProfitLossController get _profitLoss => Get.isRegistered<ProfitLossController>()
      ? Get.find<ProfitLossController>()
      : Get.put(ProfitLossController());

  List<SaleRecordModel> get filteredSales {
    final query = searchQuery.value.trim().toLowerCase();
    final range = dateRange.value;

    final sales = _profitLoss.sales.where((sale) {
      final matchesSearch = query.isEmpty ||
          sale.id.toLowerCase().contains(query) ||
          sale.cashierName.toLowerCase().contains(query);
      final matchesDate = range == null ||
          (!sale.date.isBefore(range.start) && sale.date.isBefore(range.end.add(const Duration(days: 1))));
      return matchesSearch && matchesDate;
    }).toList();

    sales.sort((a, b) => b.date.compareTo(a.date));
    return sales;
  }

  int get todaysSalesCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _profitLoss.sales.where((s) {
      final day = DateTime(s.date.year, s.date.month, s.date.day);
      return day == today;
    }).length;
  }

  double get totalRevenue => filteredSales.fold(0.0, (sum, s) => sum + s.totalRevenue);

  void updateSearchQuery(String value) => searchQuery.value = value;

  void setDateRange(DateTimeRange? range) => dateRange.value = range;
}
