import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool termsAccepted = false;

  String selectedRole = "job";

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // 🔥 اللوجو (نفس السبلاش بدون صورة)
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

  // 🔥 role card احترافي
  Widget buildRoleCard({
    required String title,
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
          padding: const EdgeInsets.symmetric(vertical: 20),
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
                size: 30,
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

              // 🔥 لوجو
              appLogo(),

              const SizedBox(height: 15),

              const Text(
                "CareerAI",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              const Text(
                "Create your professional account",
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
                    icon: Icons.person,
                    value: "job",
                  ),
                  const SizedBox(width: 12),
                  buildRoleCard(
                    title: "Company",
                    icon: Icons.business,
                    value: "company",
                  ),
                ],
              ),

              const SizedBox(height: 25),

              TextField(
                controller: fullNameController,
                decoration: customInput("Full Name", Icons.person),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: emailController,
                decoration: customInput("Email", Icons.email),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: phoneController,
                decoration: customInput("Phone Number", Icons.phone),
              ),
              const SizedBox(height: 15),

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

              const SizedBox(height: 15),

              TextField(
                controller: confirmPasswordController,
                obscureText: !confirmPasswordVisible,
                decoration: customInput("Confirm Password", Icons.shield)
                    .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            confirmPasswordVisible = !confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        termsAccepted = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "I agree to Terms & Privacy Policy",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // 🔥 زر احترافي
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
                    print("Create Account");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
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

              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
