import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pharmacy_system/core/database/app_database.dart';
import 'package:pharmacy_system/data/models/settings_model.dart';

/// SQLite-backed reads/writes for the single-row `app_settings` table.
/// `SettingsController` owns the in-memory `Rx<SettingsModel>` mirror.
class SettingsRepository {
  static const int _rowId = 1;

  Future<SettingsModel?> get() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('app_settings', where: 'id = ?', whereArgs: [_rowId], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> save(SettingsModel settings) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'app_settings',
      _toRow(settings),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, Object?> _toRow(SettingsModel s) => {
        'id': _rowId,
        'pharmacy_name': s.pharmacyName,
        'address': s.address,
        'phone': s.phone,
        'tax_rate_percent': s.taxRatePercent,
        'currency': s.currency,
        'low_stock_threshold': s.lowStockThreshold,
        'expiry_alert_lead_days': s.expiryAlertLeadDays,
        'language': s.language,
        'updated_at': DateTime.now().toIso8601String(),
      };

  SettingsModel _fromRow(Map<String, Object?> row) => SettingsModel(
        pharmacyName: row['pharmacy_name'] as String,
        address: row['address'] as String,
        phone: row['phone'] as String,
        taxRatePercent: (row['tax_rate_percent'] as num).toDouble(),
        currency: row['currency'] as String,
        lowStockThreshold: row['low_stock_threshold'] as int,
        expiryAlertLeadDays: row['expiry_alert_lead_days'] as int,
        language: row['language'] as String,
      );
}
