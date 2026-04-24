import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import '../services/notification_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void handleResetPassword() async {
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // إظهار علامة التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // إرسال طلب استعادة كلمة المرور لفايربيس
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // إغلاق مربع التحميل
        
        // 🔹 عرض الإشعار المحلي (Push Notification) 🔹
        NotificationService().showNotification(
          id: 1, 
          title: "CareerAI Password Reset", 
          body: "A reset link has been sent to your email successfully. Please check your inbox.",
          payload: 'open_mail',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reset link sent! Check your email. ✅"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        
        // العودة لصفحة تسجيل الدخول
        Navigator.pop(context); 
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context); // إغلاق مربع التحميل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Failed to send reset link."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // إغلاق مربع التحميل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
                const SizedBox(height: 35),

                CustomButton(
                  text: "Send Reset Link",
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
