import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final userController = TextEditingController();
  final passController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  void _login() async {
    if (userController.text.isEmpty || passController.text.isEmpty) {
      _showSnackBar("Please fill in all fields", Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (userController.text == "admin" && RegExp(r'^[1-9]+$').hasMatch(passController.text)) {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      _showSnackBar("Invalid Admin Credentials", Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // خلفية أفتح وأهدأ للويب
      body: Center( // لضمان التوسط التام في الشاشة
        child: SingleChildScrollView(
          child: Container(
            width: 380, // تم تصغير العرض ليكون أكثر تناسقاً (Compact)
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gemini Stars Icon - Slightly smaller
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome, 
                    size: 45, // تصغير الأيقونة قليلاً
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Career AI",
                  style: TextStyle(
                    fontSize: 26, // تصغير الخط قليلاً ليكون أنيقاً
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: 1.0,
                  ),
                ),
                const Text(
                  "ADMIN PANEL",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Login Card
                Container(
                  padding: const EdgeInsets.all(28), // تقليل البادينغ الداخلي
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.black.withOpacity(0.05)), // حدود خفيفة جداً
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      CustomInputField(
                        hint: "Username",
                        icon: Icons.person_outline,
                        controller: userController,
                      ),
                      const SizedBox(height: 16),
                      
                      CustomInputField(
                        hint: "Password",
                        icon: Icons.lock_outline,
                        controller: passController,
                        isPassword: true,
                        obscureText: _obscureText,
                        onToggleObscure: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      CustomButton(
                        text: "Login to Dashboard",
                        isLoading: _isLoading,
                        onPressed: _login,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}