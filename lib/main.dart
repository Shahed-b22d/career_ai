import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/upload_cv_screen.dart';
import 'screens/roadmap_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/post_job_screen.dart';
import 'screens/person_profile.dart';
import 'screens/company_profile.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تفعيل خدمة الإشعارات
  await NotificationService().init();
  await NotificationService().requestPermission();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed (Please configure Firebase later): $e");
  }

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
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/postJob': (context) => const PostJobScreen(),
        '/personProfile': (context) => const PersonProfile(),
        '/companyProfile': (context) => const CompanyProfileScreen(),
        '/home': (context) => const MainScreen(),
        '/uploadCV': (context) => const UploadScreen(),

        // 🔹 واجهة Roadmap مرتبطة بـ Upload CV
        '/roadmap': (context) => RoadmapScreen(),
      },

      // 🔹 Theme (تطبيق الثيم الجديد)
      theme: AppTheme.lightTheme,
    );
  }
}
