import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/inventory_movement_model.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/data/repositories/inventory_movement_repository.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';

/// Reads product/stock data from the existing [ProductsController] (single
/// source of truth — no duplicated product list here) and owns the
/// inventory-specific state: its own category/status filters and the
/// stock-movement log.
class InventoryController extends GetxController {
  static const String allCategoriesLabel = 'كل الفئات';
  static const String allStatusesLabel = 'كل الحالات';

  final InventoryMovementRepository _movementRepository = Get.find<InventoryMovementRepository>();

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = allCategoriesLabel.obs;
  final RxString selectedStatus = allStatusesLabel.obs;

  /// In-memory mirror of `inventory_movements`.
  final RxList<InventoryMovementModel> movements = <InventoryMovementModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    movements.assignAll(await _movementRepository.getAll());
  }

  ProductsController get _products => Get.isRegistered<ProductsController>()
      ? Get.find<ProductsController>()
      : Get.put(ProductsController());

  List<ProductModel> get allProducts => _products.products;

  /// Real, Settings-configurable low-stock threshold (same source
  /// `ProductsController` itself uses — no separate copy here).
  int get lowStockThreshold => _products.lowStockThreshold;

  List<String> get categories => [
        allCategoriesLabel,
        ...allProducts.map((p) => p.category).toSet(),
      ];

  List<String> get statusOptions => [
        allStatusesLabel,
        ...ProductStatus.values.map((s) => s.label),
      ];

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim();
    final threshold = lowStockThreshold; // read unconditionally, see ProductsController.filteredProducts
    return allProducts.where((product) {
      final matchesCategory =
          selectedCategory.value == allCategoriesLabel || product.category == selectedCategory.value;
      final matchesStatus =
          selectedStatus.value == allStatusesLabel || product.statusFor(threshold).label == selectedStatus.value;
      final matchesSearch = query.isEmpty || product.name.contains(query);
      return matchesCategory && matchesStatus && matchesSearch;
    }).toList();
  }

  void updateSearchQuery(String value) => searchQuery.value = value;

  void selectCategory(String category) => selectedCategory.value = category;

  void selectStatus(String status) => selectedStatus.value = status;

  String _generateMovementId() {
    final numbers = movements
        .map((m) => int.tryParse(m.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final next = (numbers.isEmpty ? 0 : numbers.reduce((a, b) => a > b ? a : b)) + 1;
    return 'MV-$next';
  }

  /// Corrects a product's stock to [newQuantity], required a [reason], and
  /// logs the change as an adjustment movement. This is the single place
  /// stock is written from the Inventory screen — the real quantity lives
  /// on [ProductModel.stock] via [ProductsController], not a local copy.
  void adjustStock({
    required ProductModel product,
    required int newQuantity,
    required AdjustmentReason reason,
  }) {
    final delta = newQuantity - product.stock;
    if (delta == 0) return;

    _products.updateProduct(product.copyWith(stock: newQuantity));

    final movement = InventoryMovementModel(
      id: _generateMovementId(),
      date: DateTime.now(),
      productId: product.id,
      productName: product.name,
      type: MovementType.adjustment,
      quantity: delta,
      reference: reason.label,
    );
    movements.insert(0, movement);
    _movementRepository.insert(movement);
  }
}
