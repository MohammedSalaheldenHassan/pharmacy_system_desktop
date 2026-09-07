import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/auth/login/presentation/controller/auth_controller.dart';

class CustomForm extends StatelessWidget {
  const CustomForm({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'أدخل بياناتك للوصول إلى نظام الصيدلية',
            style: TextStyle(fontSize: 13, fontFamily: 'Cairo', color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          _FieldLabel('اسم المستخدم'),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.username,
            style: const TextStyle(fontFamily: 'Cairo'),
            validator: controller.validateUsername,
            decoration: _fieldDecoration(
              hint: 'ادخل اسم المستخدم',
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 16),
          _FieldLabel('كلمة المرور'),
          const SizedBox(height: 6),
          Obx(
            () => TextFormField(
              controller: controller.password,
              obscureText: controller.obscurePassword.value,
              style: const TextStyle(fontFamily: 'Cairo'),
              validator: controller.validatePassword,
              onFieldSubmitted: (_) => controller.login(),
              decoration: _fieldDecoration(
                hint: 'ادخل كلمة المرور',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  onPressed: controller.toggleObscurePassword,
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.errorMessage.value.isEmpty) {
              return const SizedBox(height: 24);
            }
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 14),
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red, fontFamily: 'Cairo', fontSize: 13),
              ),
            );
          }),
          Obx(
            () => SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0e4a35),
                  disabledBackgroundColor: const Color(0xff0e4a35).withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                      )
                    : const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Cairo',
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color),
        );

    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      suffixIcon: suffixIcon,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontFamily: 'Cairo'),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(Colors.grey.shade300),
      enabledBorder: border(Colors.grey.shade300),
      focusedBorder: border(const Color(0xff0e4a35)),
      errorBorder: border(Colors.red.shade300),
      focusedErrorBorder: border(Colors.red),
      errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Cairo',
        color: Colors.grey.shade800,
      ),
    );
  }
}
