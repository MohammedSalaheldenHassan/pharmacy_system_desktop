import 'package:get/get.dart';
import 'package:pharmacy_system/data/models/inventory_movement_model.dart';
import 'package:pharmacy_system/data/models/purchase_order_model.dart';
import 'package:pharmacy_system/data/repositories/purchase_order_repository.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/inventory_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/products_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/suppliers_controller.dart';

class PurchasesController extends GetxController {
  static const String allStatusesLabel = 'كل الحالات';
  static const String allSuppliersLabel = 'كل الموردين';

  final PurchaseOrderRepository _repository = Get.find<PurchaseOrderRepository>();

  /// In-memory mirror of `purchase_orders` (+ their items).
  final RxList<PurchaseOrderModel> orders = <PurchaseOrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    orders.assignAll(await _repository.getAll());
  }

  ProductsController get _products => Get.isRegistered<ProductsController>()
      ? Get.find<ProductsController>()
      : Get.put(ProductsController());

  InventoryController get _inventory => Get.isRegistered<InventoryController>()
      ? Get.find<InventoryController>()
      : Get.put(InventoryController());

  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = allStatusesLabel.obs;
  final RxString selectedSupplierId = allSuppliersLabel.obs;

  List<String> get statusOptions => [
        allStatusesLabel,
        ...PurchaseOrderStatus.values.map((s) => s.label),
      ];

  String supplierNameFor(String supplierId) {
    if (!Get.isRegistered<SuppliersController>()) return supplierId;
    final suppliers = Get.find<SuppliersController>().suppliers;
    final match = suppliers.where((s) => s.id == supplierId);
    return match.isEmpty ? supplierId : match.first.name;
  }

  List<PurchaseOrderModel> get filteredOrders {
    final query = searchQuery.value.trim().toLowerCase();
    return orders.where((order) {
      final matchesStatus =
          selectedStatus.value == allStatusesLabel || order.status.label == selectedStatus.value;
      final matchesSupplier =
          selectedSupplierId.value == allSuppliersLabel || order.supplierId == selectedSupplierId.value;
      final matchesSearch = query.isEmpty ||
          order.id.toLowerCase().contains(query) ||
          supplierNameFor(order.supplierId).toLowerCase().contains(query);
      return matchesStatus && matchesSupplier && matchesSearch;
    }).toList();
  }

  void updateSearchQuery(String value) => searchQuery.value = value;

  void selectStatus(String status) => selectedStatus.value = status;

  void selectSupplier(String supplierId) => selectedSupplierId.value = supplierId;

  /// Number of purchase orders placed with [supplierId]. Read by the
  /// Suppliers screen to show a live order count per supplier.
  int orderCountForSupplier(String supplierId) =>
      orders.where((order) => order.supplierId == supplierId).length;

  String _generateOrderNumber() {
    final numbers = orders
        .map((o) => int.tryParse(o.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final next = (numbers.isEmpty ? 0 : numbers.reduce((a, b) => a > b ? a : b)) + 1;
    return 'PO-$next';
  }

  void createOrder({
    required String supplierId,
    required List<PurchaseOrderItem> items,
  }) {
    if (items.isEmpty) return;
    final order = PurchaseOrderModel(
      id: _generateOrderNumber(),
      supplierId: supplierId,
      date: DateTime.now(),
      items: items,
    );
    orders.add(order);
    _repository.insert(order);
  }

  /// Marks an order as received and increases real stock for each line
  /// item on the same shared product data source POS decreases — the
  /// mirror image of a sale. The status change, every stock increase, and
  /// every movement-log entry are written in one database transaction
  /// (see [PurchaseOrderRepository.receiveOrder]). Items are matched by
  /// [PurchaseOrderItem.productId] where present, falling back to matching
  /// by name for historical/mock rows that predate that field.
  Future<void> markReceived(String orderId) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    final order = orders[index];
    if (order.status == PurchaseOrderStatus.received) return;

    final stockUpdates = <ProductStockUpdate>[];
    final movements = <InventoryMovementModel>[];
    final updatedProducts = <String, int>{}; // productId -> newStock, for the in-memory mirror

    for (final item in order.items) {
      final product = item.productId != null
          ? _products.products.firstWhereOrNull((p) => p.id == item.productId)
          : _products.products.firstWhereOrNull((p) => p.name == item.productName);
      if (product == null) continue;

      final newStock = product.stock + item.quantity;
      stockUpdates.add(ProductStockUpdate(productId: product.id, newStock: newStock));
      updatedProducts[product.id] = newStock;

      movements.add(
        InventoryMovementModel(
          id: 'MV-${DateTime.now().microsecondsSinceEpoch}-${product.id}',
          date: DateTime.now(),
          productId: product.id,
          productName: product.name,
          type: MovementType.purchase,
          quantity: item.quantity,
          reference: order.id,
        ),
      );
    }

    await _repository.receiveOrder(orderId: orderId, stockUpdates: stockUpdates, movements: movements);

    // Persisted above in one transaction — only sync the in-memory mirrors now.
    for (final entry in updatedProducts.entries) {
      final product = _products.products.firstWhereOrNull((p) => p.id == entry.key);
      if (product != null) {
        _products.applyPersistedUpdate(product.copyWith(stock: entry.value));
      }
    }
    _inventory.movements.insertAll(0, movements);

    orders[index] = order.copyWith(status: PurchaseOrderStatus.received);
  }

  void cancelOrder(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    orders[index] = orders[index].copyWith(status: PurchaseOrderStatus.cancelled);
    _repository.updateStatus(orderId, PurchaseOrderStatus.cancelled);
  }
}
