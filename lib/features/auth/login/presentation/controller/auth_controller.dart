import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/mock/mock_employees.dart';
import 'package:pharmacy_system/features/dashboard/presentation/view/sidebar.dart';
import 'package:pharmacy_system/features/pos/presentation/view/pos_view.dart';

class AuthController extends GetxController {
  final formKey = GlobalKey<FormState>();

  TextEditingController? username;
  TextEditingController? password;

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

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

  Future<void> login() async {
    errorMessage.value = '';

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;

    final enteredUsername = username?.text.trim() ?? '';
    final enteredPassword = password?.text ?? '';

    // Credentials are checked against the centralized mock employee list
    // (no backend yet); an inactive employee cannot log in.
    final matches = mockEmployees.where(
      (employee) =>
          employee.username == enteredUsername &&
          employee.password == enteredPassword,
    );
    final employee = matches.isEmpty ? null : matches.first;

    if (employee == null) {
      errorMessage.value = 'اسم المستخدم أو كلمة المرور غير صحيحة';
      return;
    }
    if (!employee.isActive) {
      errorMessage.value = 'هذا الحساب غير نشط، الرجاء مراجعة المسؤول';
      return;
    }

    if (employee.role == cashierRole) {
      Get.offAll(() => const PosView());
    } else {
      Get.offAll(() => const Sidebar());
    }
  }
}
