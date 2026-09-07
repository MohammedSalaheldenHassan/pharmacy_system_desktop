import 'package:get/get.dart';
import 'package:pharmacy_system/data/repositories/employee_repository.dart';
import 'package:pharmacy_system/data/repositories/inventory_movement_repository.dart';
import 'package:pharmacy_system/data/repositories/product_repository.dart';
import 'package:pharmacy_system/data/repositories/purchase_order_repository.dart';
import 'package:pharmacy_system/data/repositories/sale_repository.dart';
import 'package:pharmacy_system/data/repositories/settings_repository.dart';
import 'package:pharmacy_system/data/repositories/supplier_repository.dart';

/// Registers every repository once, lazily, at app start. Controllers
/// fetch them with `Get.find()` — never construct a repository directly.
/// New repositories are added here as each one is built.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(() => ProductRepository());
    Get.lazyPut<SupplierRepository>(() => SupplierRepository());
    Get.lazyPut<PurchaseOrderRepository>(() => PurchaseOrderRepository());
    Get.lazyPut<InventoryMovementRepository>(() => InventoryMovementRepository());
    Get.lazyPut<SaleRepository>(() => SaleRepository());
    Get.lazyPut<SettingsRepository>(() => SettingsRepository());
    Get.lazyPut<EmployeeRepository>(() => EmployeeRepository());
  }
}
