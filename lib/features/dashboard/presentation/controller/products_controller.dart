import 'package:get/get.dart';
import 'package:pharmacy_system/core/mock/mock_products.dart';
import 'package:pharmacy_system/core/mock/models/product_model.dart';

class ProductsController extends GetxController {
  static const String allCategoriesLabel = 'كل الفئات';
  static const String allStatusesLabel = 'كل الحالات';

  final RxList<ProductModel> products = <ProductModel>[...mockProducts].obs;

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
    return products.where((product) {
      final matchesCategory = selectedCategory.value == allCategoriesLabel ||
          product.category == selectedCategory.value;
      final matchesStatus = selectedStatus.value == allStatusesLabel ||
          product.status.label == selectedStatus.value;
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
    products.add(
      ProductModel(
        id: _generateId(),
        name: name,
        genericName: genericName,
        category: category,
        barcode: barcode,
        sellingPrice: sellingPrice,
        stock: stock,
        expiryDate: expiryDate,
      ),
    );
  }

  void updateProduct(ProductModel updated) {
    final index = products.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      products[index] = updated;
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
  }
}
