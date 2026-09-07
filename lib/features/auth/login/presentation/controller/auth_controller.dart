import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/constant/default_admin.dart';
import 'package:pharmacy_system/core/constant/roles.dart';
import 'package:pharmacy_system/data/models/employee_model.dart';
import 'package:pharmacy_system/data/repositories/employee_repository.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/sidebar.dart';
import 'package:pharmacy_system/features/pos/presentation/view/pos_view.dart';

class AuthController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final EmployeeRepository _employeeRepository = Get.find<EmployeeRepository>();

  TextEditingController? username;
  TextEditingController? password;

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// The employee who is currently logged in, so any screen can show the
  /// real name/role instead of a hardcoded placeholder.
  final Rxn<EmployeeModel> currentUser = Rxn<EmployeeModel>();

  @override
  void onInit() {
    super.onInit();
    username = TextEditingController();
    password = TextEditingController();
  }

  @override
  void onClose() {
    username?.dispose();
    password?.dispose();
    super.onClose();
  }

  final List<DropdownMenuEntry<String>> language = [
    DropdownMenuEntry(value: 'ar', label: 'العربية'),
    DropdownMenuEntry(value: 'en', label: 'English'),
  ];

  void changeLanguage(String? languageCode) {
    if (languageCode == null) return;
    Get.updateLocale(Locale(languageCode));
  }

  void toggleObscurePassword() =>
      obscurePassword.value = !obscurePassword.value;

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال اسم المستخدم';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 4) {
      return 'كلمة المرور قصيرة جدًا';
    }
    return null;
  }

  /// A fresh database starts with no employees at all — this creates the
  /// one starting admin account ([defaultAdminEmployee]) the first time
  /// login is attempted, so there's always a way in. Every other table
  /// stays genuinely empty; this is the sole exception, the same way a
  /// fresh install needs *some* starting settings row.
  Future<void> _ensureEmployeesSeeded() async {
    final existing = await _employeeRepository.getAll();
    if (existing.isEmpty) {
      await _employeeRepository.insert(defaultAdminEmployee);
    }
  }

  Future<void> login() async {
    errorMessage.value = '';

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isLoading.value = true;
    await _ensureEmployeesSeeded();
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;

    final enteredUsername = username?.text.trim() ?? '';
    final enteredPassword = password?.text ?? '';

    // Verified against the hashed password stored in SQLite — the
    // plaintext is never compared or stored. An inactive employee cannot
    // log in even with the correct password.
    final employee = await _employeeRepository.verifyCredentials(enteredUsername, enteredPassword);

    if (employee == null) {
      errorMessage.value = 'اسم المستخدم أو كلمة المرور غير صحيحة';
      return;
    }
    if (!employee.isActive) {
      errorMessage.value = 'هذا الحساب غير نشط، الرجاء مراجعة المسؤول';
      return;
    }

    currentUser.value = employee;

    if (employee.role == cashierRole) {
      Get.offAll(() => const PosView());
    } else {
      Get.offAll(() => const Sidebar());
    }
  }
}
