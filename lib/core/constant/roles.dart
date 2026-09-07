/// Role name used to route a logged-in employee to the POS screen instead
/// of the admin dashboard. See [AuthController].
const String cashierRole = 'كاشير';
const String adminRole = 'مدير';

/// The only roles an employee can be assigned in this system.
const List<String> employeeRoles = [adminRole, cashierRole];
