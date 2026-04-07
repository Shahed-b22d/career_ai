import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  bool isPasswordVisible = false;
  bool isConfirmVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void handleResetPassword() async {
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // 🔹 محاكاة تغيير كلمة المرور والاتصال بالسيرفر
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // إغلاق مربع التحميل
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset successfully! ✅"),
          backgroundColor: Colors.green,
        ),
      );
      
      // العودة لصفحة تسجيل الدخول
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Reset Password"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset_rounded, size: 40, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                
                Text(
                  "Create New Password",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  "Enter your email and a new password to reset your account access.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 35),

                CustomInputField(
                  hint: "Email address",
                  icon: Icons.email_outlined,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                CustomInputField(
                  hint: "New Password",
                  icon: Icons.lock_outline_rounded,
                  controller: newPasswordController,
                  isPassword: true,
                  obscureText: !isPasswordVisible,
                  onToggleObscure: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 16),

                CustomInputField(
                  hint: "Confirm New Password",
                  icon: Icons.lock_outline_rounded,
                  controller: confirmPasswordController,
                  isPassword: true,
                  obscureText: !isConfirmVisible,
                  onToggleObscure: () {
                    setState(() {
                      isConfirmVisible = !isConfirmVisible;
                    });
                  },
                ),
                const SizedBox(height: 35),

                CustomButton(
                  text: "Reset Password",
                  onPressed: handleResetPassword,
                ),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
