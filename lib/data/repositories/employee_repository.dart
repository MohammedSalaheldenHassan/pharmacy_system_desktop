import 'package:pharmacy_system/core/database/app_database.dart';
import 'package:pharmacy_system/core/utils/password_hasher.dart';
import 'package:pharmacy_system/data/models/employee_model.dart';

/// SQLite-backed CRUD for employees. Passwords are never stored or
/// returned in plain text: [insert] hashes before writing, [getAll] never
/// exposes the hash (every returned [EmployeeModel.password] is `''`), and
/// [verifyCredentials] is the only way to check a password, done entirely
/// inside the database layer.
class EmployeeRepository {
  Future<List<EmployeeModel>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('employees', orderBy: 'name');
    return rows.map(_fromRow).toList();
  }

  Future<void> insert(EmployeeModel employee) async {
    final db = await AppDatabase.instance.database;
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(employee.password, salt);
    await db.insert('employees', _toRow(employee, passwordHash: hash, passwordSalt: salt));
  }

  /// Updates an employee. If [employee.password] is empty (the form's
  /// password field is left blank when editing, since the real password
  /// is never sent back to the UI to prefill), the stored password hash
  /// is left untouched; otherwise it's rehashed with a fresh salt.
  Future<void> update(EmployeeModel employee) async {
    final db = await AppDatabase.instance.database;
    final row = _toRow(employee, passwordHash: null, passwordSalt: null);

    if (employee.password.isNotEmpty) {
      final salt = PasswordHasher.generateSalt();
      row['password_hash'] = PasswordHasher.hash(employee.password, salt);
      row['password_salt'] = salt;
    } else {
      row.remove('password_hash');
      row.remove('password_salt');
    }

    await db.update('employees', row, where: 'id = ?', whereArgs: [employee.id]);
  }

  Future<void> delete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns the matching employee (password never populated) if
  /// [username]/[password] are correct, or null otherwise. Active/inactive
  /// is not checked here — callers (AuthController) decide what to do
  /// with an inactive account.
  Future<EmployeeModel?> verifyCredentials(String username, String password) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('employees', where: 'username = ?', whereArgs: [username], limit: 1);
    if (rows.isEmpty) return null;

    final row = rows.first;
    final salt = row['password_salt'] as String;
    final hash = row['password_hash'] as String;
    if (!PasswordHasher.verify(password, salt, hash)) return null;

    return _fromRow(row);
  }

  Map<String, Object?> _toRow(
    EmployeeModel e, {
    required String? passwordHash,
    required String? passwordSalt,
  }) {
    final row = <String, Object?>{
      'id': e.id,
      'name': e.name,
      'username': e.username,
      'email': e.email,
      'phone': e.phone,
      'role': e.role,
      'join_date': e.joinDate.toIso8601String(),
      'is_active': e.isActive ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (passwordHash != null) row['password_hash'] = passwordHash;
    if (passwordSalt != null) row['password_salt'] = passwordSalt;
    return row;
  }

  EmployeeModel _fromRow(Map<String, Object?> row) => EmployeeModel(
        id: row['id'] as String,
        name: row['name'] as String,
        username: row['username'] as String,
        // Never populated from a read — see the class doc comment.
        password: '',
        email: row['email'] as String,
        phone: row['phone'] as String,
        role: row['role'] as String,
        joinDate: DateTime.parse(row['join_date'] as String),
        isActive: (row['is_active'] as int) == 1,
      );
}
