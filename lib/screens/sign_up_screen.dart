import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import '../services/ai_api_service.dart';

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
  final businessTypeController = TextEditingController();
  final otherBusinessTypeController = TextEditingController();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool termsAccepted = false;

  String selectedRole = "job";
  String? selectedBusinessType;

  File? commercialRegisterFile;

  final List<String> companyTypes = [
    "Technology / IT",
    "E-commerce",
    "Finance / Banking",
    "Healthcare",
    "Education",
    "Construction",
    "Real Estate",
    "Marketing / Advertising",
    "Manufacturing",
    "Transport & Logistics",
    "Hospitality & Tourism",
    "Other",
  ];

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    businessTypeController.dispose();
    otherBusinessTypeController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await GoogleSignIn.instance.authenticate();
      } catch (e) {
        if (mounted) Navigator.pop(context);
        return;
      }

      if (googleUser == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pop(context);
        if (selectedRole == 'company') {
          Navigator.pushReplacementNamed(context, '/companyDashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/userDashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In failed: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.grey.withOpacity(0.2),
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
                    color:
                        isSelected
                            ? Colors.white
                            : AppTheme.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    if (selectedRole == "company" && commercialRegisterFile == null) {
      showError("Upload commercial register");
      return false;
    }
    return true;
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Create Account",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join CareerAI to accelerate your growth.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  buildRoleCard(
                    title: "Job Seeker",
                    icon: Icons.person_rounded,
                    value: "job",
                  ),
                  const SizedBox(width: 16),
                  buildRoleCard(
                    title: "Company",
                    icon: Icons.business_rounded,
                    value: "company",
                  ),
                ],
              ),

              const SizedBox(height: 30),

              CustomInputField(
                hint: "Full Name",
                icon: Icons.person_outline_rounded,
                controller: fullNameController,
              ),
              const SizedBox(height: 16),

              CustomInputField(
                hint: "Email address",
                icon: Icons.email_outlined,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CustomInputField(
                hint: "Phone Number",
                icon: Icons.phone_outlined,
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),

              if (selectedRole == "company") ...[
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedBusinessType,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.work_outline_rounded),
                    hintText: "Select Business Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items:
                      companyTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBusinessType = value;
                    });
                  },
                ),

                if (selectedBusinessType == "Other") ...[
                  const SizedBox(height: 12),
                  CustomInputField(
                    hint: "Enter your business type",
                    icon: Icons.edit_outlined,
                    controller: otherBusinessTypeController,
                  ),
                ],

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [
                            'pdf',
                            'png',
                            'jpg',
                            'jpeg',
                          ],
                        );

                    if (result != null) {
                      setState(() {
                        commercialRegisterFile = File(
                          result.files.single.path!,
                        );
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    commercialRegisterFile == null
                        ? "Upload Commercial Register"
                        : "File Selected ✓",
                  ),
                ),
              ],

              const SizedBox(height: 16),

              CustomInputField(
                hint: "Password",
                icon: Icons.lock_outline_rounded,
                controller: passwordController,
                isPassword: true,
                obscureText: !passwordVisible,
                onToggleObscure: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),

              const SizedBox(height: 16),

              CustomInputField(
                hint: "Confirm Password",
                icon: Icons.lock_outline_rounded,
                controller: confirmPasswordController,
                isPassword: true,
                obscureText: !confirmPasswordVisible,
                onToggleObscure: () {
                  setState(() {
                    confirmPasswordVisible = !confirmPasswordVisible;
                  });
                },
              ),

              const SizedBox(height: 20),

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
                      "I agree to the Terms of Service & Privacy Policy",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: "Create Account",
                onPressed: () async {
                  if (!validate()) return;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final result = await AiApiService.register(
                      name: fullNameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text,
                      role: selectedRole,
                      phone: phoneController.text.trim(),
                      businessType:
                          selectedRole == 'company'
                              ? (selectedBusinessType == "Other"
                                  ? otherBusinessTypeController.text.trim()
                                  : selectedBusinessType)
                              : null,
                      commercialRegisterFile:
                          selectedRole == 'company' ? commercialRegisterFile : null,
                    );

                    if (mounted) Navigator.pop(context);

                    // register() throws on error, so if we reach here it succeeded
                    final role = result['user']?['role'] ?? selectedRole;
                    Navigator.pushReplacementNamed(
                      context,
                      role == "job" ? '/userDashboard' : '/companyDashboard',
                    );
                  } catch (e) {
                    if (mounted) Navigator.pop(context);
                    showError(e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}