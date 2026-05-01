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
import 'screens/company_dashboard.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'screens/user_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  // تفعيل خدمة الإشعارات
  await NotificationService().init();
  await NotificationService().requestPermission();
 
  try {
    await Firebase.initializeApp();
   
    // إعداد مكتبة جوجل الجديدة (v7) بالمعرف الخاص بالويب
    await GoogleSignIn.instance.initialize(
      serverClientId: '642116540552-4f8v4824t9m73v3chfs2s17bed1nnf35.apps.googleusercontent.com',
    );
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
        '/home': (context) => MainScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/postJob': (context) => const PostJobScreen(),
        '/personProfile': (context) => const PersonProfile(),
        '/companyProfile': (context) => const CompanyProfileScreen(),
        '/companyDashboard': (context) => const CompanyDashboard(),
        '/uploadCV': (context) => const UploadScreen(),
        '/userDashboard': (context) =>  UserDashboard(),
        // 🔹 واجهة Roadmap مرتبطة ب ـ Upload CV
        '/roadmap': (context) => RoadmapScreen(),
      },

      // 🔹 Theme (تطبيق الثيم الجديد)
      theme: AppTheme.lightTheme,
    );
  }
}