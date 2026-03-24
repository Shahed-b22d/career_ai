import 'package:flutter/material.dart';

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
      initialRoute: '/login',

      // 🔥 ربط الصفحات
      routes: {
        '/login': (context) => const AuthAndRoleSelectionWidget(),
        '/signup': (context) => const SignUpScreen(),
      },

      // 🔥 شكل التطبيق
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
<<<<<<< HEAD
      home: PersonProfile(),
=======
>>>>>>> 20fa8fd52b05f3dcf47fdf3959b7e40e9a47323e
    );
  }
}
