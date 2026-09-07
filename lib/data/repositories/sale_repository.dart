import 'package:pharmacy_system/core/database/app_database.dart';
import 'package:pharmacy_system/data/models/inventory_movement_model.dart';
import 'package:pharmacy_system/data/models/sale_record_model.dart';
import 'package:pharmacy_system/data/repositories/purchase_order_repository.dart' show ProductStockUpdate;

/// SQLite-backed CRUD for the historical sales ledger. `ProfitLossController`
/// owns the in-memory `RxList` mirror (also read by Sales, Reports,
/// Dashboard — one shared list, no duplication).
class SaleRepository {
  Future<List<SaleRecordModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final saleRows = await db.query('sales', orderBy: 'date DESC');

    final sales = <SaleRecordModel>[];
    for (final row in saleRows) {
      final itemRows = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [row['id']]);
      sales.add(
        SaleRecordModel(
          id: row['id'] as String,
          date: DateTime.parse(row['date'] as String),
          cashierName: row['cashier_name'] as String,
          items: itemRows
              .map((i) => SaleRecordItem(
                    productId: i['product_id'] as String?,
                    productName: i['product_name'] as String,
                    category: i['category'] as String,
                    quantity: i['quantity'] as int,
                    unitPrice: (i['unit_price'] as num).toDouble(),
                    costPrice: (i['cost_price'] as num).toDouble(),
                  ))
              .toList(),
        ),
      );
    }
    return sales;
  }

  /// Plain (non-transactional) insert — used only to seed the database
  /// from the old mock ledger on first run.
  Future<void> insert(SaleRecordModel sale) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      await txn.insert('sales', {
        'id': sale.id,
        'date': sale.date.toIso8601String(),
        'cashier_name': sale.cashierName,
        'updated_at': DateTime.now().toIso8601String(),
      });
      for (final item in sale.items) {
        await txn.insert('sale_items', _itemRow(sale.id, item));
      }
    });
  }

  /// Records a completed POS checkout: inserts the sale + its items,
  /// decrements stock for each product, and logs an inventory movement
  /// per line — all in a single transaction, the mirror image of
  /// [PurchaseOrderRepository.receiveOrder].
  Future<void> createSale({
    required SaleRecordModel sale,
    required List<ProductStockUpdate> stockUpdates,
    required List<InventoryMovementModel> movements,
  }) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final batch = txn.batch();

      batch.insert('sales', {
        'id': sale.id,
        'date': sale.date.toIso8601String(),
        'cashier_name': sale.cashierName,
        'updated_at': now,
      });

      for (final item in sale.items) {
        batch.insert('sale_items', _itemRow(sale.id, item));
      }

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

  Map<String, Object?> _itemRow(String saleId, SaleRecordItem item) => {
        'sale_id': saleId,
        'product_id': item.productId,
        'product_name': item.productName,
        'category': item.category,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'cost_price': item.costPrice,
      };
}
