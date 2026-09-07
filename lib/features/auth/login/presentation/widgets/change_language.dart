import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/auth/login/presentation/controller/auth_controller.dart';

/// Language selector for the login screen. [light] switches to a
/// translucent style suitable for placement over a dark/colored background.
class ChangeLanguage extends StatelessWidget {
  const ChangeLanguage({super.key, this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    final Color fg = light ? Colors.white : const Color(0xff0e4a35);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: light ? Colors.white.withValues(alpha: 0.15) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: light ? Colors.white.withValues(alpha: 0.4) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, color: fg, size: 20),
          DropdownMenu<String>(
            dropdownMenuEntries: controller.language,
            initialSelection: Get.locale?.languageCode ?? 'ar',
            onSelected: controller.changeLanguage,
            textStyle: TextStyle(fontFamily: 'Cairo', color: fg, fontSize: 14),
            inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 6),
            ),
          ),
        ],
      ),
    );
  }
}
