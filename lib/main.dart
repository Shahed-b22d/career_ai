import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 اسم التطبيق
      title: 'CareerAI',

      // 🔥 أول شاشة
      initialRoute: '/',

      // 🔥 ربط الصفحات
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const AuthAndRoleSelectionWidget(),
        '/signup': (context) => const SignUpScreen(),
      },

      // 🔥 شكل التطبيق
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}
