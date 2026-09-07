import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/auth/login/presentation/controller/auth_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/controller/dashboard_controller.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/dashboard_product_info.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/dashboard_sels_info.dart';
import 'package:pharmacy_system/features/dashboard/presentation/widgets/dashboard_top_bar.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 50,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
            child: const Icon(Icons.menu),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
              const Positioned(
                child: Padding(
                  padding: EdgeInsets.only(top: 4, right: 4),
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.green,
                    child: Text("1", style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 10)),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                  child: const Icon(Icons.person_2_outlined),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final user = Get.isRegistered<AuthController>()
                          ? Get.find<AuthController>().currentUser.value
                          : null;
                      return Text(user?.name ?? 'مدير', style: const TextStyle(fontFamily: 'Cairo'));
                    }),
                    const SizedBox(height: 2.5),
                    Obx(() {
                      final user = Get.isRegistered<AuthController>()
                          ? Get.find<AuthController>().currentUser.value
                          : null;
                      return Text(user?.role ?? 'مدير النظام', style: const TextStyle(fontFamily: 'Cairo'));
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
        elevation: 0,
        shadowColor: Colors.black12,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DashboardTopBar(),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(flex: 60, child: DashboardSelsInfo()),
                    const SizedBox(width: 20),
                    const Expanded(flex: 40, child: DashboardProductInfo()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
