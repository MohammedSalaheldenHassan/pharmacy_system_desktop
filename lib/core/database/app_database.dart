import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Every main table gets these three columns for the future sync phase.
/// No sync logic reads/writes them yet — they're just reserved.
const String syncColumns = '''
  is_dirty INTEGER NOT NULL DEFAULT 1,
  server_id TEXT,
  updated_at TEXT NOT NULL
''';

/// Owns the single SQLite connection for the whole app. On desktop
/// (Linux/Windows/macOS) plain `sqflite` has no native implementation, so
/// this initializes the FFI-backed `databaseFactory` before opening —
/// mobile targets would use the default factory instead, but this app is
/// desktop-only today (see README_UI_STATE.md).
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const int _schemaVersion = 1;
  Database? _db;

  /// Guards the first open against concurrent callers. The sidebar's
  /// `IndexedStack` builds all 11 pages at once, so every controller's
  /// `onInit()` calls [database] for the very first time in the same
  /// frame — without this, each one would independently see `_db == null`
  /// and race to open (and `CREATE TABLE`) the same file concurrently.
  Future<Database>? _opening;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _opening ??= _open();
    _db = await _opening;
    return _db!;
  }

  Future<Database> _open() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'pharmacy_system.db');

    return openDatabase(
      path,
      version: _schemaVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await _createSchema(db);
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        join_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        $syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        generic_name TEXT NOT NULL DEFAULT '',
        concentration TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL,
        barcode TEXT NOT NULL DEFAULT '',
        selling_price REAL NOT NULL,
        stock INTEGER NOT NULL,
        expiry_date TEXT NOT NULL,
        $syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        contact_person TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        $syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE purchase_orders (
        id TEXT PRIMARY KEY,
        supplier_id TEXT NOT NULL REFERENCES suppliers(id),
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        $syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE purchase_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
        product_id TEXT REFERENCES products(id),
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        cost_price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        cashier_name TEXT NOT NULL,
        $syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id TEXT NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
        product_id TEXT REFERENCES products(id),
        product_name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        cost_price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory_movements (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        product_id TEXT REFERENCES products(id),
        product_name TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        reference TEXT NOT NULL,
        $syncColumns
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        pharmacy_name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        tax_rate_percent REAL NOT NULL,
        currency TEXT NOT NULL,
        low_stock_threshold INTEGER NOT NULL,
        expiry_alert_lead_days INTEGER NOT NULL,
        language TEXT NOT NULL,
        $syncColumns
      )
    ''');
  }

  /// Test-only / dev-reset hook. Not called anywhere in production code.
  Future<void> close() async {
    await _db?.close();
    _db = null;
    _opening = null;
  }

  /// Test-only: (re)opens this singleton against a fresh in-memory
  /// database with the same schema, so repository tests exercise real
  /// SQL/transactions without touching a file on disk. Not called
  /// anywhere in production code.
  Future<Database> openForTest() async {
    await close();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: _schemaVersion,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async => _createSchema(db),
      ),
    );
    return _db!;
  }
}
