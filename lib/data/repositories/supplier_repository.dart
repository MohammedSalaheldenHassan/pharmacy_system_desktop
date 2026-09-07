import 'package:pharmacy_system/core/database/app_database.dart';
import 'package:pharmacy_system/data/models/supplier_model.dart';

/// SQLite-backed CRUD for suppliers. `SuppliersController` owns the
/// in-memory `RxList` mirror and calls through here to persist changes.
class SupplierRepository {
  Future<List<SupplierModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('suppliers', orderBy: 'name');
    return rows.map(_fromRow).toList();
  }

  Future<void> insert(SupplierModel supplier) async {
    final db = await AppDatabase.instance.database;
    await db.insert('suppliers', _toRow(supplier));
  }

  Future<void> update(SupplierModel supplier) async {
    final db = await AppDatabase.instance.database;
    await db.update('suppliers', _toRow(supplier), where: 'id = ?', whereArgs: [supplier.id]);
  }

  Future<void> delete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _toRow(SupplierModel s) => {
        'id': s.id,
        'name': s.name,
        'contact_person': s.contactPerson,
        'phone': s.phone,
        'email': s.email,
        'address': s.address,
        'updated_at': DateTime.now().toIso8601String(),
      };

  SupplierModel _fromRow(Map<String, Object?> row) => SupplierModel(
        id: row['id'] as String,
        name: row['name'] as String,
        contactPerson: row['contact_person'] as String,
        phone: row['phone'] as String,
        email: row['email'] as String,
        address: row['address'] as String,
      );
}
