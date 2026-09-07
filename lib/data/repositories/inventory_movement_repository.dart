import 'package:pharmacy_system/core/database/app_database.dart';
import 'package:pharmacy_system/data/models/inventory_movement_model.dart';

/// SQLite-backed reads/writes for the stock-movement log.
/// `InventoryController` owns the in-memory `RxList` mirror.
class InventoryMovementRepository {
  Future<List<InventoryMovementModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('inventory_movements', orderBy: 'date DESC');
    return rows.map(_fromRow).toList();
  }

  Future<void> insert(InventoryMovementModel movement) async {
    final db = await AppDatabase.instance.database;
    await db.insert('inventory_movements', _toRow(movement));
  }

  Map<String, Object?> _toRow(InventoryMovementModel m) => {
        'id': m.id,
        'date': m.date.toIso8601String(),
        'product_id': m.productId,
        'product_name': m.productName,
        'type': m.type.name,
        'quantity': m.quantity,
        'reference': m.reference,
        'updated_at': DateTime.now().toIso8601String(),
      };

  InventoryMovementModel _fromRow(Map<String, Object?> row) => InventoryMovementModel(
        id: row['id'] as String,
        date: DateTime.parse(row['date'] as String),
        productId: row['product_id'] as String?,
        productName: row['product_name'] as String,
        type: MovementType.values.byName(row['type'] as String),
        quantity: row['quantity'] as int,
        reference: row['reference'] as String,
      );
}
