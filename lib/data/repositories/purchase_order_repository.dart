import 'package:pharmacy_system/core/database/app_database.dart';
import 'package:pharmacy_system/data/models/inventory_movement_model.dart';
import 'package:pharmacy_system/data/models/purchase_order_model.dart';

/// Precomputed stock change applied when an order is received — the
/// controller decides the new stock value (same arithmetic it always
/// used), this repository just persists it atomically.
class ProductStockUpdate {
  final String productId;
  final int newStock;
  const ProductStockUpdate({required this.productId, required this.newStock});
}

/// SQLite-backed CRUD for purchase orders + their line items.
/// `PurchasesController` owns the in-memory `RxList` mirror.
class PurchaseOrderRepository {
  Future<List<PurchaseOrderModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final orderRows = await db.query('purchase_orders', orderBy: 'date DESC');

    final orders = <PurchaseOrderModel>[];
    for (final row in orderRows) {
      final itemRows = await db.query(
        'purchase_order_items',
        where: 'order_id = ?',
        whereArgs: [row['id']],
      );
      orders.add(
        PurchaseOrderModel(
          id: row['id'] as String,
          supplierId: row['supplier_id'] as String,
          date: DateTime.parse(row['date'] as String),
          status: PurchaseOrderStatus.values.byName(row['status'] as String),
          items: itemRows
              .map((i) => PurchaseOrderItem(
                    productId: i['product_id'] as String?,
                    productName: i['product_name'] as String,
                    quantity: i['quantity'] as int,
                    costPrice: (i['cost_price'] as num).toDouble(),
                  ))
              .toList(),
        ),
      );
    }
    return orders;
  }

  /// Inserts the order and all its line items in one transaction.
  Future<void> insert(PurchaseOrderModel order) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      await txn.insert('purchase_orders', {
        'id': order.id,
        'supplier_id': order.supplierId,
        'date': order.date.toIso8601String(),
        'status': order.status.name,
        'updated_at': DateTime.now().toIso8601String(),
      });
      for (final item in order.items) {
        await txn.insert('purchase_order_items', {
          'order_id': order.id,
          'product_id': item.productId,
          'product_name': item.productName,
          'quantity': item.quantity,
          'cost_price': item.costPrice,
        });
      }
    });
  }

  Future<void> updateStatus(String orderId, PurchaseOrderStatus status) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'purchase_orders',
      {'status': status.name, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  /// Marks the order received, increases stock for each product, and logs
  /// an inventory movement per line — all in a single transaction, the
  /// mirror image of a POS sale.
  Future<void> receiveOrder({
    required String orderId,
    required List<ProductStockUpdate> stockUpdates,
    required List<InventoryMovementModel> movements,
  }) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final batch = txn.batch();

      batch.update(
        'purchase_orders',
        {'status': PurchaseOrderStatus.received.name, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [orderId],
      );

      for (final update in stockUpdates) {
        batch.update(
          'products',
          {'stock': update.newStock, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [update.productId],
        );
      }

      for (final movement in movements) {
        batch.insert('inventory_movements', {
          'id': movement.id,
          'date': movement.date.toIso8601String(),
          'product_id': movement.productId,
          'product_name': movement.productName,
          'type': movement.type.name,
          'quantity': movement.quantity,
          'reference': movement.reference,
          'updated_at': now,
        });
      }

      await batch.commit(noResult: true);
    });
  }
}
