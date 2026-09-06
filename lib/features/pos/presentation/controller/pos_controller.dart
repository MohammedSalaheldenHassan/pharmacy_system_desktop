import 'package:get/get.dart';
import 'package:pharmacy_system/features/pos/data/cart_item_model.dart';
import 'package:pharmacy_system/core/mock/mock_products.dart';
import 'package:pharmacy_system/core/mock/models/product_model.dart';

/// Pharmacy business constants used to compute the invoice totals.
const double _taxRate = 0.15; // 15% VAT
const double _discountRate = 0.0; // no discount by default

class PosController extends GetxController {
  static const String allCategoriesLabel = 'الكل';

  final RxList<ProductModel> _allProducts = <ProductModel>[...mockProducts].obs;
  final RxList<CartItemModel> cart = <CartItemModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = allCategoriesLabel.obs;
  final RxBool checkoutSuccess = false.obs;

  List<String> get categories => [allCategoriesLabel, ...mockProductCategories];

  /// Products filtered by the current search query and selected category.
  List<ProductModel> get filteredProducts {
    return _allProducts.where((product) {
      final matchesCategory = selectedCategory.value == allCategoriesLabel ||
          product.category == selectedCategory.value;
      final query = searchQuery.value.trim();
      final matchesSearch = query.isEmpty ||
          product.name.contains(query) ||
          product.concentration.contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void updateSearchQuery(String value) => searchQuery.value = value;

  void selectCategory(String category) => selectedCategory.value = category;

  void addToCart(ProductModel product) {
    final index = cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cart[index].quantity++;
      cart.refresh();
    } else {
      cart.add(CartItemModel(product: product));
    }
  }

  void increaseQuantity(CartItemModel item) {
    item.quantity++;
    cart.refresh();
  }

  void decreaseQuantity(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      cart.refresh();
    } else {
      removeFromCart(item);
    }
  }

  void removeFromCart(CartItemModel item) {
    cart.removeWhere((element) => element.product.id == item.product.id);
  }

  void clearCart() => cart.clear();

  int get itemCount => cart.length;

  double get subtotal =>
      cart.fold(0.0, (sum, item) => sum + item.total);

  double get discount => subtotal * _discountRate;

  double get taxableAmount => subtotal - discount;

  double get tax => taxableAmount * _taxRate;

  double get grandTotal => taxableAmount + tax;

  /// Completes the sale: clears the cart and briefly flips
  /// [checkoutSuccess] to show a success state/snackbar in the UI.
  void checkout() {
    if (cart.isEmpty) return;
    clearCart();
    checkoutSuccess.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      checkoutSuccess.value = false;
    });
  }
}
