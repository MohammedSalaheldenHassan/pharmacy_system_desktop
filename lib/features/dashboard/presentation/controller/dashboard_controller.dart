import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/employees_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/expiry_alerts_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/profit_loss_controller.dart';

class DailySalesPoint {
  final DateTime day;
  final double revenue;

  const DailySalesPoint({required this.day, required this.revenue});
}

/// Aggregates numbers from the other feature controllers — the Dashboard
/// owns no data of its own (Dashboard is built first in the sidebar's
/// IndexedStack, so every dependency below is created here on first use).
class DashboardController extends GetxController {
  ProductsController get _products => Get.isRegistered<ProductsController>()
      ? Get.find<ProductsController>()
      : Get.put(ProductsController());

  EmployeesController get _employees => Get.isRegistered<EmployeesController>()
      ? Get.find<EmployeesController>()
      : Get.put(EmployeesController());

  ProfitLossController get _profitLoss => Get.isRegistered<ProfitLossController>()
      ? Get.find<ProfitLossController>()
      : Get.put(ProfitLossController());

  ExpiryAlertsController get _expiryAlerts => Get.isRegistered<ExpiryAlertsController>()
      ? Get.find<ExpiryAlertsController>()
      : Get.put(ExpiryAlertsController());

  double get todaysSales {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _profitLoss.sales
        .where((s) => !s.date.isBefore(today) && s.date.isBefore(tomorrow))
        .fold(0.0, (sum, s) => sum + s.totalRevenue);
  }

  int get lowStockCount => _products.products
      .where((p) {
        final s = p.statusFor(_products.lowStockThreshold);
        return s == ProductStatus.lowStock || s == ProductStatus.outOfStock;
      })
      .length;

  int get expiryAlertsCount => _expiryAlerts.expiredCount + _expiryAlerts.expiringSoonCount;

  int get activeEmployeesCount => _employees.employees.where((e) => e.isActive).length;

  /// Fixed last-7-days window, independent of whatever period is currently
  /// selected on the Profit & Loss screen.
  List<DailySalesPoint> get last7DaysSales {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));

    final Map<DateTime, double> byDay = {
      for (var i = 0; i < 7; i++) start.add(Duration(days: i)): 0.0,
    };
    for (final sale in _profitLoss.sales) {
      final day = DateTime(sale.date.year, sale.date.month, sale.date.day);
      if (byDay.containsKey(day)) {
        byDay[day] = byDay[day]! + sale.totalRevenue;
      }
    }
    final days = byDay.keys.toList()..sort();
    return [for (final d in days) DailySalesPoint(day: d, revenue: byDay[d]!)];
  }

  List<ProductModel> get topLowStockProducts => _products.products.where((p) {
        final s = p.statusFor(_products.lowStockThreshold);
        return s == ProductStatus.lowStock || s == ProductStatus.outOfStock;
      }).take(4).toList();

  List<ProductModel> get topExpiryAlerts => _expiryAlerts.alerts.take(4).toList();
}
