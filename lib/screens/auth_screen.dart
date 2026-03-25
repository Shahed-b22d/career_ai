import 'package:flutter/material.dart';

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

  // 🔥 نفس لوجو السبلاش
  Widget appLogo() {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E66F5), Color(0xFFFFD600)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.black, size: 35),
    );
  }

  // 🔥 input احترافي
  InputDecoration customInput(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
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
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? Colors.white : Colors.blue,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white70 : Colors.grey,
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
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔥 Logo
              appLogo(),

              const SizedBox(height: 15),

              const Text(
                "CareerAI",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              const Text(
                "Welcome back 👋",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "I am a...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  buildRoleCard(
                    title: "Job Seeker",
                    description: "Find jobs & learn",
                    icon: Icons.person,
                    value: "job",
                  ),
                  const SizedBox(width: 12),
                  buildRoleCard(
                    title: "Company",
                    description: "Hire talent",
                    icon: Icons.business,
                    value: "company",
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🔥 Email
              TextField(
                controller: emailController,
                decoration: customInput("Email", Icons.email),
              ),

              const SizedBox(height: 15),

              // 🔥 Password
              TextField(
                controller: passwordController,
                obscureText: !passwordVisible,
                decoration: customInput("Password", Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 15),

              // 🔥 زر Login احترافي (Gradient)
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    print("Login pressed");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 🔥 زر Sign Up
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text("Create New Account"),
              ),

              const SizedBox(height: 25),

              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text("Continue with Google"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "By continuing, you agree to our Terms & Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
