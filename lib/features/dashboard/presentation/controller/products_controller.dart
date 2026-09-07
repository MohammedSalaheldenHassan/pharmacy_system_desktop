import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/data/repositories/product_repository.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/settings_controller.dart';

class ProductsController extends GetxController {
  static const String allCategoriesLabel = 'كل الفئات';
  static const String allStatusesLabel = 'كل الحالات';

  final ProductRepository _repository = Get.find<ProductRepository>();

  /// In-memory mirror of the `products` table — every screen reads this
  /// RxList exactly as before; every mutation below writes through to
  /// SQLite via [_repository] as well.
  final RxList<ProductModel> products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    products.assignAll(await _repository.getAll());
  }

  SettingsController get _settings => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController());

  /// The real, Settings-configurable low-stock threshold — the single
  /// place every screen should read it from, so it can never drift out of
  /// sync with what the Settings screen actually shows.
  int get lowStockThreshold => _settings.settings.value.lowStockThreshold;

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = allCategoriesLabel.obs;
  final RxString selectedStatus = allStatusesLabel.obs;

  List<String> get categories => [
        allCategoriesLabel,
        ...products.map((p) => p.category).toSet(),
      ];

  List<String> get statusOptions => [
        allStatusesLabel,
        ...ProductStatus.values.map((s) => s.label),
      ];

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim();
    // Read unconditionally (not just inside the status-filter branch) so an
    // Obx wrapping this getter always subscribes to Settings changes, even
    // with no filter applied and short-circuit evaluation in play below.
    final threshold = lowStockThreshold;
    return products.where((product) {
      final matchesCategory = selectedCategory.value == allCategoriesLabel ||
          product.category == selectedCategory.value;
      final matchesStatus = selectedStatus.value == allStatusesLabel ||
          product.statusFor(threshold).label == selectedStatus.value;
      final matchesSearch = query.isEmpty ||
          product.name.contains(query) ||
          product.genericName.toLowerCase().contains(query.toLowerCase()) ||
          product.barcode.contains(query);
      return matchesCategory && matchesStatus && matchesSearch;
    }).toList();
  }

  void updateSearchQuery(String value) => searchQuery.value = value;

  void selectCategory(String category) => selectedCategory.value = category;

  void selectStatus(String status) => selectedStatus.value = status;

  String _generateId() {
    final numbers = products
        .map((p) => int.tryParse(p.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final next = (numbers.isEmpty ? 0 : numbers.reduce((a, b) => a > b ? a : b)) + 1;
    return 'MED${next.toString().padLeft(3, '0')}';
  }

  void addProduct({
    required String name,
    required String genericName,
    required String category,
    required String barcode,
    required double sellingPrice,
    required int stock,
    required DateTime expiryDate,
  }) {
    final product = ProductModel(
      id: _generateId(),
      name: name,
      genericName: genericName,
      category: category,
      barcode: barcode,
      sellingPrice: sellingPrice,
      stock: stock,
      expiryDate: expiryDate,
    );
    products.add(product);
    _repository.insert(product);
  }

  void updateProduct(ProductModel updated) {
    final index = products.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      products[index] = updated;
      _repository.update(updated);
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    _repository.delete(id);
  }

  /// Updates only the in-memory mirror — for callers (Purchases' received-
  /// order flow) that already persisted the new stock themselves inside
  /// their own transaction, so this must NOT write to the database again.
  void applyPersistedUpdate(ProductModel updated) {
    final index = products.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      products[index] = updated;
    }
  }
}
