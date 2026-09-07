import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/auth/login/presentation/controller/auth_controller.dart';
import 'package:pharmacy_system/features/auth/login/presentation/widgets/change_language.dart';
import 'package:pharmacy_system/features/auth/login/presentation/widgets/custom_form.dart';
import 'package:pharmacy_system/features/auth/login/presentation/widgets/pharm_info.dart';

/// Below this width the branding panel is dropped and the form is shown
/// centered on its own, so the screen still fits comfortably.
const double _wideLayoutBreakpoint = 900;

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F6F4),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= _wideLayoutBreakpoint;
            return Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isWide ? 960 : 480),
                      child: isWide
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 620, child: _WideLoginCard()),
                                const SizedBox(height: 16),
                                Text(
                                  'جميع الحقوق محفوظة لصيدلية الشفاء',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontFamily: 'Cairo'),
                                ),
                              ],
                            )
                          : const _CompactLoginCard(),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: ChangeLanguage(light: isWide),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Side-by-side branding + form layout for wide desktop windows.
class _WideLoginCard extends StatelessWidget {
  const _WideLoginCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff1B4332), Color(0xff0e4a35)],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: PharmInfo(light: true)),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: const Center(
                child: SingleChildScrollView(child: CustomForm()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stacked branding + form layout for narrow windows.
class _CompactLoginCard extends StatelessWidget {
  const _CompactLoginCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PharmInfo(compact: true),
        const SizedBox(height: 24),
        Material(
          elevation: 8,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: CustomForm(),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'جميع الحقوق محفوظة لصيدلية الشفاء',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontFamily: 'Cairo'),
        ),
      ],
    );
  }
}
