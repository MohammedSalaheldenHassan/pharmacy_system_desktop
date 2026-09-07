// Canonical employee model shared by every feature that needs employee/user
// data (Auth login, Employees management, ...).

enum EmployeeStatus { active, inactive }

extension EmployeeStatusLabel on EmployeeStatus {
  String get label => this == EmployeeStatus.active ? 'نشط' : 'غير نشط';
}

class EmployeeModel {
  final String id;
  final String name;
  final String username;
  final String password;
  final String email;
  final String phone;
  final String role;
  final DateTime joinDate;
  final bool isActive;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.role,
    required this.joinDate,
    this.isActive = true,
  });

  EmployeeStatus get status =>
      isActive ? EmployeeStatus.active : EmployeeStatus.inactive;

  EmployeeModel copyWith({
    String? name,
    String? username,
    String? password,
    String? email,
    String? phone,
    String? role,
    DateTime? joinDate,
    bool? isActive,
  }) {
    return EmployeeModel(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
