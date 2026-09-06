import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        backgroundColor: const Color(0xff386641),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(color: Colors.white),
                child: const Icon(Icons.local_hospital, color: Color(0xff386641)),
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
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Color(0xff386641)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "محمد صلاح",
                          style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                        ),
                        Text(
                          "كاشير",
                          style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                  ],
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
