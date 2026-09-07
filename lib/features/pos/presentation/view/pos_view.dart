import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/auth/login/presentation/controller/auth_controller.dart';
import 'package:pharmacy_system/features/auth/login/presentation/view/login_view.dart';
import 'package:pharmacy_system/features/pos/presentation/controller/pos_controller.dart';
import 'package:pharmacy_system/features/pos/presentation/widgets/cart_container.dart';
import 'package:pharmacy_system/features/pos/presentation/widgets/product_container.dart';

class PosView extends StatelessWidget {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PosController());

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: const Color(0xff0e4a35),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(color: Colors.white),
                child: const Icon(Icons.local_hospital, color: Color(0xff0e4a35)),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "صيدلية الشفاء",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Cairo'),
                  ),
                  Text(
                    "نقطة البيع",
                    style: TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ],
          ),
        ),
        leadingWidth: 200,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  height: 35,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.4),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Color(0xff0e4a35)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final user = Get.isRegistered<AuthController>()
                              ? Get.find<AuthController>().currentUser.value
                              : null;
                          return Text(
                            user?.name ?? 'كاشير',
                            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                          );
                        }),
                        Obx(() {
                          final user = Get.isRegistered<AuthController>()
                              ? Get.find<AuthController>().currentUser.value
                              : null;
                          return Text(
                            user?.role ?? 'كاشير',
                            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                if (Navigator.canPop(context))
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'رجوع',
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                IconButton(
                  onPressed: () {
                    Get.offAll(() => LoginView());
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xffEEEEEE),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Row(
          children: [ProductContainer(), SizedBox(width: 10), CartContainer()],
        ),
      ),
    );
  }
}
