import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/upload_cv_screen.dart';
import 'screens/roadmap_screen.dart';
import 'screens/person_profile.dart';
import 'screens/company_profile.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareerAI',

      // 🔹 أول شاشة
      initialRoute: '/',

      // 🔹 ربط الصفحات
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const AuthAndRoleSelectionWidget(),
        '/signup': (context) => const SignUpScreen(),
        '/personProfile': (context) => const PersonProfile(),
        '/companyProfile': (context) => const CompanyProfileScreen(),
        '/home': (context) => const MainScreen(),
        '/uploadCV': (context) => const UploadScreen(),

        // 🔹 واجهة Roadmap مرتبطة بـ Upload CV
        '/roadmap': (context) => RoadmapScreen(),
      },

      // 🔹 Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}
