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
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.blue,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
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

  InputDecoration customInput(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 35,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "CareerAI",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const Text(
                "Create your professional account",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "I am a...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              // 🔥 Row بدل Column
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

              const SizedBox(height: 25),

              TextField(
                controller: emailController,
                decoration: customInput("Email", Icons.email),
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

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 10),

              // 🔥 زر Login احترافي
              ElevatedButton(
                onPressed: () {
                  print("Login pressed");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

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
                child: const Text("Sign Up"),
              ),

              const SizedBox(height: 20),

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

              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text("Continue with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
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
