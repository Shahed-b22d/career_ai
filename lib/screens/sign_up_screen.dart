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

  // 🔥 الجديد
  final businessTypeController = TextEditingController();

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

    // 🔥 الجديد
    businessTypeController.dispose();

    super.dispose();
  }

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

  // 🔥 validation بسيط
  bool validate() {
    if (fullNameController.text.length < 3) {
      showError("Name too short");
      return false;
    }
    if (!emailController.text.contains("@")) {
      showError("Invalid email");
      return false;
    }
    if (phoneController.text.length != 10) {
      showError("Phone must be 10 digits");
      return false;
    }
    if (passwordController.text.length < 6) {
      showError("Password too short");
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      showError("Passwords do not match");
      return false;
    }
    if (!termsAccepted) {
      showError("Accept terms first");
      return false;
    }
    return true;
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
              const SizedBox(height: 40),

              const Text(
                "Create Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

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
                keyboardType: TextInputType.number,
                decoration: customInput("Phone Number", Icons.phone),
              ),

              // 🔥 الجديد (يظهر فقط للشركة)
              if (selectedRole == "company") ...[
                const SizedBox(height: 15),
                TextField(
                  controller: businessTypeController,
                  decoration: customInput("Business Type", Icons.work),
                ),
              ],

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
                decoration: customInput("Confirm Password", Icons.lock)
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
                    if (!validate()) return;

                    Navigator.pushReplacementNamed(
                      context,
                      selectedRole == "job"
                          ? '/personProfile'
                          : '/companyProfile',
                      arguments: {
                        "name": fullNameController.text,
                        "email": emailController.text,
                        "phone": phoneController.text,

                        // 🔥 الجديد
                        "businessType": businessTypeController.text,
                      },
                    );
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
            ],
          ),
        ),
      ),
    );
  }
}
