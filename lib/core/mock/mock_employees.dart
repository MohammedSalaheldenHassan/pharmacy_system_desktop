import 'package:pharmacy_system/core/mock/models/employee_model.dart';

/// Role name used to route a logged-in employee to the POS screen instead
/// of the admin dashboard. See [AuthController].
const String cashierRole = 'كاشير';
const String adminRole = 'مدير';

/// The only roles an employee can be assigned in this system.
const List<String> employeeRoles = [adminRole, cashierRole];

/// Centralized mock employee/user data for the whole project (no
/// backend/API/database yet). Used by Auth (login credentials) and by the
/// Employees management screen.
final List<EmployeeModel> mockEmployees = [
  EmployeeModel(
    id: 'EMP001',
    name: 'محمد صلاح',
    username: 'MoSalah',
    password: '1234',
    email: 'mosalah@pharmacy.com',
    phone: '0912345678',
    role: cashierRole,
    joinDate: DateTime(2023, 3, 1),
  ),
  EmployeeModel(
    id: 'EMP002',
    name: 'أحمد محمد',
    username: 'mosalah',
    password: '1234',
    email: 'ahmed@pharmacy.com',
    phone: '0911111111',
    role: adminRole,
    joinDate: DateTime(2021, 6, 15),
  ),
  EmployeeModel(
    id: 'EMP003',
    name: 'سارة أحمد',
    username: 'sara',
    password: '1234',
    email: 'sara@pharmacy.com',
    phone: '0922222222',
    role: cashierRole,
    joinDate: DateTime(2022, 9, 10),
  ),
  EmployeeModel(
    id: 'EMP004',
    name: 'خالد حسن',
    username: 'khaled',
    password: '1234',
    email: 'khaled@pharmacy.com',
    phone: '0933333333',
    role: cashierRole,
    joinDate: DateTime(2022, 1, 20),
    isActive: false,
  ),
  EmployeeModel(
    id: 'EMP005',
    name: 'ليلى إبراهيم',
    username: 'layla',
    password: '1234',
    email: 'layla@pharmacy.com',
    phone: '0944444444',
    role: adminRole,
    joinDate: DateTime(2023, 7, 5),
  ),
  EmployeeModel(
    id: 'EMP006',
    name: 'عمر يوسف',
    username: 'omar',
    password: '1234',
    email: 'omar@pharmacy.com',
    phone: '0955555555',
    role: adminRole,
    joinDate: DateTime(2020, 11, 2),
  ),
];
