import 'package:get/get.dart';
import 'package:pharmacy_system/core/constant/default_admin.dart';
import 'package:pharmacy_system/data/models/employee_model.dart';
import 'package:pharmacy_system/data/repositories/employee_repository.dart';

class EmployeesController extends GetxController {
  static const String allRolesLabel = 'كل الأدوار';
  static const String allStatusesLabel = 'كل الحالات';

  final EmployeeRepository _repository = Get.find<EmployeeRepository>();

  /// In-memory mirror of `employees`. Passwords are never populated here
  /// except transiently right after this session's own add/edit — see
  /// [EmployeeRepository]'s doc comment.
  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final stored = await _repository.getAll();
    if (stored.isEmpty) {
      // Defensive fallback only — in practice AuthController already
      // seeds this same single admin account before the Sidebar (and
      // this controller) ever exists.
      await _repository.insert(defaultAdminEmployee);
      employees.assignAll([defaultAdminEmployee]);
    } else {
      employees.assignAll(stored);
    }
  }

  List<String> get roles => [
        allRolesLabel,
        ...employees.map((e) => e.role).toSet(),
      ];

  List<String> get statusOptions => [
        allStatusesLabel,
        ...EmployeeStatus.values.map((s) => s.label),
      ];

  List<EmployeeModel> get filteredEmployees {
    final query = searchQuery.value.trim().toLowerCase();
    return employees.where((employee) {
      final matchesRole =
          selectedRole.value == allRolesLabel || employee.role == selectedRole.value;
      final matchesStatus = selectedStatus.value == allStatusesLabel ||
          employee.status.label == selectedStatus.value;
      final matchesSearch = query.isEmpty ||
          employee.name.toLowerCase().contains(query) ||
          employee.email.toLowerCase().contains(query) ||
          employee.phone.contains(query) ||
          employee.id.toLowerCase().contains(query);
      return matchesRole && matchesStatus && matchesSearch;
    }).toList();
  }

  int get activeCount => employees.where((e) => e.isActive).length;
  int get inactiveCount => employees.where((e) => !e.isActive).length;

  final RxString searchQuery = ''.obs;
  final RxString selectedRole = allRolesLabel.obs;
  final RxString selectedStatus = allStatusesLabel.obs;

  void updateSearchQuery(String value) => searchQuery.value = value;

  void selectRole(String role) => selectedRole.value = role;

  void selectStatus(String status) => selectedStatus.value = status;

  String _generateId() {
    final numbers = employees
        .map((e) => int.tryParse(e.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final next = (numbers.isEmpty ? 0 : numbers.reduce((a, b) => a > b ? a : b)) + 1;
    return 'EMP${next.toString().padLeft(3, '0')}';
  }

  void addEmployee({
    required String name,
    required String username,
    required String password,
    required String email,
    required String phone,
    required String role,
    required DateTime joinDate,
  }) {
    final employee = EmployeeModel(
      id: _generateId(),
      name: name,
      username: username,
      password: password,
      email: email,
      phone: phone,
      role: role,
      joinDate: joinDate,
    );
    employees.add(employee);
    _repository.insert(employee);
  }

  /// If [updated.password] is empty (the edit form's password field left
  /// blank), the stored password is left unchanged.
  void updateEmployee(EmployeeModel updated) {
    final index = employees.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      employees[index] = updated;
      _repository.update(updated);
    }
  }

  void deleteEmployee(String id) {
    employees.removeWhere((e) => e.id == id);
    _repository.delete(id);
  }

  void toggleActive(EmployeeModel employee) {
    updateEmployee(employee.copyWith(isActive: !employee.isActive, password: ''));
  }
}
