import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/features/auth/login/presentation/view/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmacy System',
      theme: ThemeData.light(),
      locale: Locale('ar'),
      home: LoginView(),
    );
  }
}
