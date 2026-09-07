import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/supplier_model.dart';
import 'package:pharmacy_system/data/repositories/supplier_repository.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/purchases_controller.dart';

class SuppliersController extends GetxController {
  final SupplierRepository _repository = Get.find<SupplierRepository>();

  /// In-memory mirror of the `suppliers` table.
  final RxList<SupplierModel> suppliers = <SupplierModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    suppliers.assignAll(await _repository.getAll());
  }

  final RxString searchQuery = ''.obs;

  List<SupplierModel> get filteredSuppliers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return suppliers;
    return suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(query) ||
          supplier.contactPerson.toLowerCase().contains(query) ||
          supplier.phone.contains(query) ||
          supplier.email.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearchQuery(String value) => searchQuery.value = value;

  /// The Purchases controller, created on first use if the Purchases
  /// screen hasn't been built yet (the sidebar's IndexedStack builds every
  /// page up front, but Suppliers is built before Purchases, so this can't
  /// assume Purchases has already registered its controller).
  PurchasesController get _purchases => Get.isRegistered<PurchasesController>()
      ? Get.find<PurchasesController>()
      : Get.put(PurchasesController());

  /// Number of purchase orders linked to a supplier, read from the
  /// Purchases screen's mock data. Call this from inside an [Obx] to stay
  /// reactive to new/changed purchase orders.
  int purchaseOrderCountFor(String supplierId) =>
      _purchases.orderCountForSupplier(supplierId);

  String _generateId() {
    final numbers = suppliers
        .map((s) => int.tryParse(s.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final next = (numbers.isEmpty ? 0 : numbers.reduce((a, b) => a > b ? a : b)) + 1;
    return 'SUP${next.toString().padLeft(3, '0')}';
  }

  void addSupplier({
    required String name,
    required String contactPerson,
    required String phone,
    required String email,
    required String address,
  }) {
    final supplier = SupplierModel(
      id: _generateId(),
      name: name,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      address: address,
    );
    suppliers.add(supplier);
    _repository.insert(supplier);
  }

  void updateSupplier(SupplierModel updated) {
    final index = suppliers.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      suppliers[index] = updated;
      _repository.update(updated);
    }
  }

  void deleteSupplier(String id) {
    suppliers.removeWhere((s) => s.id == id);
    _repository.delete(id);
  }
}
