import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
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
      title: 'CareerAI',

      initialRoute: '/',

      routes: {
        '/': (context) =>
            kIsWeb ? const AdminLoginScreen() : const SplashScreen(),
        '/login': (context) => const AuthAndRoleSelectionWidget(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => MainScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/postJob': (context) => const PostJobScreen(),
        '/personProfile': (context) => const PersonProfile(),
        '/companyProfile': (context) => const CompanyProfileScreen(),
        '/companyDashboard': (context) => const CompanyDashboard(),
        '/uploadCV': (context) => const UploadScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/aiInsights': (context) => const AiInsightsScreen(),
        '/candidateProfile': (context) => const CandidateProfileScreen(),
        '/jobDetails': (context) => const JobDetailsScreen(),
        '/activeJobs': (context) => const ActiveJobsScreen(),
        '/suggestedProfiles': (context) => const SuggestedProfilesScreen(),
        '/billing': (context) => const BillingScreen(),
        '/userDashboard': (context) => UserDashboard(),
        '/admin': (context) => AdminDashboardPro(),
        '/adminLogin': (context) => const AdminLoginScreen(),
      },

      theme: AppTheme.lightTheme,
    );
  }
}
