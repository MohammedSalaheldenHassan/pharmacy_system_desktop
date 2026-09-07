import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_system/core/database/app_database.dart';
import 'package:pharmacy_system/data/models/inventory_movement_model.dart';
import 'package:pharmacy_system/data/models/product_model.dart';
import 'package:pharmacy_system/data/models/purchase_order_model.dart';
import 'package:pharmacy_system/data/models/sale_record_model.dart';
import 'package:pharmacy_system/data/models/supplier_model.dart';
import 'package:pharmacy_system/data/repositories/inventory_movement_repository.dart';
import 'package:pharmacy_system/data/repositories/product_repository.dart';
import 'package:pharmacy_system/data/repositories/purchase_order_repository.dart';
import 'package:pharmacy_system/data/repositories/sale_repository.dart';
import 'package:pharmacy_system/data/repositories/supplier_repository.dart';

void main() {
  late ProductRepository products;
  late SaleRepository sales;
  late PurchaseOrderRepository purchaseOrders;
  late InventoryMovementRepository movements;
  late SupplierRepository suppliers;

  const productId = 'MED001';

  setUp(() async {
    await AppDatabase.instance.openForTest();
    products = ProductRepository();
    sales = SaleRepository();
    purchaseOrders = PurchaseOrderRepository();
    movements = InventoryMovementRepository();
    suppliers = SupplierRepository();

    await products.insert(
      ProductModel(
        id: productId,
        name: 'باراسيتامول',
        category: 'مسكنات',
        sellingPrice: 3.5,
        stock: 20,
        expiryDate: DateTime(2099, 1, 1),
      ),
    );
    await suppliers.insert(
      const SupplierModel(
        id: 'SUP001',
        name: 'شركة الاختبار',
        contactPerson: 'شخص',
        phone: '000',
        email: 'a@a.com',
        address: 'عنوان',
      ),
    );
  });

  tearDown(() => AppDatabase.instance.close());

  group('SaleRepository.createSale', () {
    test('decrements stock, inserts the sale, and logs a sale movement in one transaction', () async {
      await sales.createSale(
        sale: SaleRecordModel(
          id: 'INV-1',
          date: DateTime.now(),
          cashierName: 'كاشير الاختبار',
          items: const [
            SaleRecordItem(
              productId: productId,
              productName: 'باراسيتامول',
              category: 'مسكنات',
              quantity: 5,
              unitPrice: 3.5,
              costPrice: 2.0,
            ),
          ],
        ),
        stockUpdates: const [ProductStockUpdate(productId: productId, newStock: 15)],
        movements: [
          InventoryMovementModel(
            id: 'MV-1',
            date: DateTime.now(),
            productId: productId,
            productName: 'باراسيتامول',
            type: MovementType.sale,
            quantity: -5,
            reference: 'INV-1',
          ),
        ],
      );

      final updatedProducts = await products.getAll();
      expect(updatedProducts.single.stock, 15);

      final storedSales = await sales.getAll();
      expect(storedSales, hasLength(1));
      expect(storedSales.single.items.single.quantity, 5);

      final storedMovements = await movements.getAll();
      expect(storedMovements, hasLength(1));
      expect(storedMovements.single.type, MovementType.sale);
      expect(storedMovements.single.quantity, -5);
    });
  });

  group('PurchaseOrderRepository.receiveOrder', () {
    test('increases stock, marks the order received, and logs a purchase movement in one transaction', () async {
      final order = PurchaseOrderModel(
        id: 'PO-1',
        supplierId: 'SUP001',
        date: DateTime(2026, 1, 1),
        items: const [
          PurchaseOrderItem(productId: productId, productName: 'باراسيتامول', quantity: 10, costPrice: 2.0),
        ],
      );
      await purchaseOrders.insert(order);

      await purchaseOrders.receiveOrder(
        orderId: 'PO-1',
        stockUpdates: const [ProductStockUpdate(productId: productId, newStock: 30)],
        movements: [
          InventoryMovementModel(
            id: 'MV-2',
            date: DateTime.now(),
            productId: productId,
            productName: 'باراسيتامول',
            type: MovementType.purchase,
            quantity: 10,
            reference: 'PO-1',
          ),
        ],
      );

      final updatedProducts = await products.getAll();
      expect(updatedProducts.single.stock, 30);

      final storedOrders = await purchaseOrders.getAll();
      expect(storedOrders.single.status, PurchaseOrderStatus.received);

      final storedMovements = await movements.getAll();
      expect(storedMovements, hasLength(1));
      expect(storedMovements.single.type, MovementType.purchase);
      expect(storedMovements.single.quantity, 10);
    });
  });
}
