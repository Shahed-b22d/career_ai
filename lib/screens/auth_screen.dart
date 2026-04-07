import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';

class AuthAndRoleSelectionWidget extends StatefulWidget {
  const AuthAndRoleSelectionWidget({super.key});

  @override
  State<AuthAndRoleSelectionWidget> createState() =>
      _AuthAndRoleSelectionWidgetState();
}

class _AuthAndRoleSelectionWidgetState
    extends State<AuthAndRoleSelectionWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool passwordVisible = false;
  String selectedRole = "job";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // 🔥 Logo 
  Widget appLogo() {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
    );
  }

  // 🔥 Role Card مطور
  Widget buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required String value,
  }) {
    final isSelected = selectedRole == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white70 : AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // 🔥 Logo
                appLogo(),
                const SizedBox(height: 20),

                Text(
                  "CareerAI",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Welcome back 👋",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 35),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "I am a...",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    buildRoleCard(
                      title: "Job Seeker",
                      description: "Find jobs & learn",
                      icon: Icons.person_rounded,
                      value: "job",
                    ),
                    const SizedBox(width: 16),
                    buildRoleCard(
                      title: "Company",
                      description: "Hire talent",
                      icon: Icons.business_rounded,
                      value: "company",
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // 🔥 Email
                CustomInputField(
                  hint: "Email address",
                  icon: Icons.email_rounded,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // 🔥 Password
                CustomInputField(
                  hint: "Password",
                  icon: Icons.lock_rounded,
                  controller: passwordController,
                  isPassword: true,
                  obscureText: !passwordVisible,
                  onToggleObscure: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgotPassword');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 🔥 Login Button 
                CustomButton(
                  text: "Login",
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                const SizedBox(height: 16),

                // 🔥 Sign Up Button
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text(
                    "Create New Account",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: TextStyle(color: AppTheme.textSecondaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 25),

                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      // 🔹 تمت محاكاة تسجيل الدخول هنا لتخطي خطأ التحزيم (Compile Error)
                      // لتعمل مكتبة google_sign_in بشكل حقيقي على الأندرويد، يجب ضبط ملفات Firebase (google-services.json)
                      // وكذلك تعديل ملفات build.gradle، وإلا سيفشل التطبيق في الإقلاع.
                      
                      /* 
                      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
                      final account = await googleSignIn.signIn(); 
                      */
                      
                      // - - - - - - - محاكاة مؤقتة - - - - - - -
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );
                      
                      await Future.delayed(const Duration(seconds: 2)); // محاكاة وقت التحميل
                      
                      if (mounted) {
                        Navigator.pop(context); // إغلاق شاشة التحميل
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Welcome, User! (Simulated)'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                      
                    } catch (error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Google Sign-In failed or cancelled."),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      print("Google Sign In Error: $error");
                    }
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 36, color: Colors.blue),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(fontSize: 16, color: AppTheme.textPrimaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  "By continuing, you agree to our Terms & Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
