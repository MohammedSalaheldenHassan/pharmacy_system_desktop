import 'package:pharmacy_system/core/constant/roles.dart';
import 'package:pharmacy_system/data/models/employee_model.dart';

/// The one account a fresh install is seeded with, so there's a way to log
/// in before any real employee has been created. Not sample/mock business
/// data — every other table starts genuinely empty (see AuthController
/// and EmployeesController).
///
/// Username: admin  Password: admin123
final EmployeeModel defaultAdminEmployee = EmployeeModel(
  id: 'EMP000',
  name: 'مدير النظام',
  username: 'admin',
  password: 'admin123',
  email: 'admin@pharmacy.com',
  phone: '0900000000',
  role: adminRole,
  joinDate: DateTime.now(),
);
