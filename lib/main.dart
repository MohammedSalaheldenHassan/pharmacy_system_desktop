import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_system/core/di/bindings.dart';
import 'package:pharmacy_system/features/auth/login/presentation/view/login_view.dart';

void main() {
  // Catches anything that isn't already caught closer to where it
  // happened (e.g. a native platform failure inside a widget callback we
  // didn't wrap ourselves) and logs it instead of letting it disappear
  // silently — a release Windows build has no attached console, so
  // without this, a failure here would look identical to a plain hang.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}\n${details.stack}');
  };

  runZonedGuarded(
    () => runApp(const MyApp()),
    (error, stackTrace) {
      debugPrint('[Uncaught] $error\n$stackTrace');
    },
  );
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
      initialBinding: AppBindings(),
      home: LoginView(),
    );
  }
}
