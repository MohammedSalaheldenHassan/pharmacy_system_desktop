import 'package:pharmacy_system/core/database/app_database.dart';
import 'package:pharmacy_system/data/models/product_model.dart';

/// SQLite-backed CRUD for products. `ProductsController` is the only
/// consumer — it owns the in-memory `RxList` mirror and calls through here
/// to persist every change.
class ProductRepository {
  Future<List<ProductModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('products', orderBy: 'name');
    return rows.map(_fromRow).toList();
  }

  Future<void> insert(ProductModel product) async {
    final db = await AppDatabase.instance.database;
    await db.insert('products', _toRow(product));
  }

  Future<void> update(ProductModel product) async {
    final db = await AppDatabase.instance.database;
    await db.update('products', _toRow(product), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<void> delete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _toRow(ProductModel p) => {
        'id': p.id,
        'name': p.name,
        'generic_name': p.genericName,
        'concentration': p.concentration,
        'category': p.category,
        'barcode': p.barcode,
        'selling_price': p.sellingPrice,
        'stock': p.stock,
        'expiry_date': p.expiryDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

  ProductModel _fromRow(Map<String, Object?> row) => ProductModel(
        id: row['id'] as String,
        name: row['name'] as String,
        genericName: row['generic_name'] as String? ?? '',
        concentration: row['concentration'] as String? ?? '',
        category: row['category'] as String,
        barcode: row['barcode'] as String? ?? '',
        sellingPrice: (row['selling_price'] as num).toDouble(),
        stock: row['stock'] as int,
        expiryDate: DateTime.parse(row['expiry_date'] as String),
      );
}
