import 'package:get/get.dart';
import 'package:pharmacy_system/features/auth/login/presentation/controller/auth_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/inventory_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/profit_loss_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/settings_controller.dart';
import 'package:pharmacy_system/features/pos/data/cart_item_model.dart';
import 'package:pharmacy_system/features/pos/data/sale_model.dart';
import 'package:pharmacy_system/data/models/inventory_movement_model.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/data/models/sale_record_model.dart';
import 'package:pharmacy_system/data/repositories/purchase_order_repository.dart' show ProductStockUpdate;
import 'package:pharmacy_system/data/repositories/sale_repository.dart';

const double _discountRate = 0.0; // no discount by default

/// Payment methods offered at checkout.
const String cashPaymentMethod = 'نقدي';
const String cardPaymentMethod = 'بطاقة';

class PosController extends GetxController {
  static const String allCategoriesLabel = 'الكل';
  static const List<String> paymentMethods = [cashPaymentMethod, cardPaymentMethod];

  final RxList<CartItemModel> cart = <CartItemModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = allCategoriesLabel.obs;
  final RxBool checkoutSuccess = false.obs;

  /// The most recently completed sale, used to generate the receipt.
  final Rxn<SaleModel> lastSale = Rxn<SaleModel>();

  int _invoiceSequence = 1000;

  /// Same product list Products/Inventory read and write — POS must never
  /// hold its own copy, or a sale here would silently drift out of sync
  /// with the stock shown everywhere else.
  ProductsController get _products => Get.isRegistered<ProductsController>()
      ? Get.find<ProductsController>()
      : Get.put(ProductsController());

  /// The shared historical sales ledger (also read by Sales, Profit &
  /// Loss, Reports, Dashboard) — a completed checkout is appended here so
  /// those screens reflect it immediately.
  ProfitLossController get _profitLoss => Get.isRegistered<ProfitLossController>()
      ? Get.find<ProfitLossController>()
      : Get.put(ProfitLossController());

  SettingsController get _settings => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController());

  InventoryController get _inventory => Get.isRegistered<InventoryController>()
      ? Get.find<InventoryController>()
      : Get.put(InventoryController());

  final SaleRepository _saleRepository = Get.find<SaleRepository>();

  List<String> get categories =>
      [allCategoriesLabel, ..._products.products.map((p) => p.category).toSet()];

  /// Products filtered by the current search query and selected category.
  List<ProductModel> get filteredProducts {
    return _products.products.where((product) {
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

  /// Real tax rate from Settings (stored there as a whole percent, e.g.
  /// 15 for 15%) — not a local hardcoded constant.
  double get taxRate => _settings.settings.value.taxRatePercent / 100;

  double get tax => taxableAmount * taxRate;

  double get grandTotal => taxableAmount + tax;

  /// The employee currently logged in, read from the existing Auth state.
  String get _cashierName {
    if (!Get.isRegistered<AuthController>()) return 'كاشير';
    final auth = Get.find<AuthController>();
    final loggedInName = auth.currentUser.value?.name;
    if (loggedInName != null && loggedInName.isNotEmpty) return loggedInName;
    final text = auth.username?.text.trim();
    return (text == null || text.isEmpty) ? 'كاشير' : text;
  }

  String _generateInvoiceNumber() {
    _invoiceSequence++;
    return 'INV-$_invoiceSequence';
  }

  /// Completes the sale: in one database transaction, decrements real
  /// stock on the shared product data source, inserts the sale + its
  /// items into the shared ledger, and logs an inventory movement per
  /// line (see [SaleRepository.createSale] — the mirror image of a
  /// received purchase order). Then syncs the in-memory mirrors, snapshots
  /// the cart into a [SaleModel] (the receipt data), clears the cart, and
  /// briefly flips [checkoutSuccess]. Returns the generated sale so the
  /// caller can open the receipt preview, or null if the cart was empty.
  Future<SaleModel?> completeSale({
    required String paymentMethod,
    required double amountPaid,
  }) async {
    if (cart.isEmpty) return null;

    final invoiceNumber = _generateInvoiceNumber();
    final now = DateTime.now();
    final cashierName = _cashierName;

    final stockUpdates = <ProductStockUpdate>[];
    final movements = <InventoryMovementModel>[];
    final saleItems = <SaleRecordItem>[];
    final newStockByProductId = <String, int>{};

    // Cost price isn't tracked on ProductModel yet, so it's approximated
    // the same way the rest of the mock ledger is (65% of selling price)
    // — a modeling gap to close once a real cost field exists.
    for (final item in cart) {
      final current = _products.products.firstWhereOrNull((p) => p.id == item.product.id);
      if (current == null) continue;

      final newStock = (current.stock - item.quantity).clamp(0, current.stock);
      stockUpdates.add(ProductStockUpdate(productId: current.id, newStock: newStock));
      newStockByProductId[current.id] = newStock;

      movements.add(
        InventoryMovementModel(
          id: 'MV-${DateTime.now().microsecondsSinceEpoch}-${current.id}',
          date: now,
          productId: current.id,
          productName: current.name,
          type: MovementType.sale,
          quantity: -item.quantity,
          reference: invoiceNumber,
        ),
      );

      saleItems.add(
        SaleRecordItem(
          productId: current.id,
          productName: current.name,
          category: current.category,
          quantity: item.quantity,
          unitPrice: current.price,
          costPrice: current.price * 0.65,
        ),
      );
    }

    final saleRecord = SaleRecordModel(id: invoiceNumber, date: now, cashierName: cashierName, items: saleItems);

    await _saleRepository.createSale(sale: saleRecord, stockUpdates: stockUpdates, movements: movements);

    // Persisted above in one transaction — only sync the in-memory
    // mirrors now (Products/Inventory/Profit & Loss all read these).
    for (final entry in newStockByProductId.entries) {
      final product = _products.products.firstWhereOrNull((p) => p.id == entry.key);
      if (product != null) {
        _products.applyPersistedUpdate(product.copyWith(stock: entry.value));
      }
    }
    _inventory.movements.insertAll(0, movements);
    _profitLoss.sales.add(saleRecord);

    final sale = SaleModel(
      invoiceNumber: invoiceNumber,
      dateTime: now,
      cashierName: cashierName,
      items: cart
          .map((item) => SaleItem(
                name: item.product.name,
                quantity: item.quantity,
                unitPrice: item.product.price,
              ))
          .toList(),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: grandTotal,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
    );

    lastSale.value = sale;
    clearCart();
    checkoutSuccess.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      checkoutSuccess.value = false;
    });

    return sale;
  }
}
