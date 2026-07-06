import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/ai_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';

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
  final otherBusinessTypeController = TextEditingController();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool termsAccepted = false;

  String selectedRole = "job";
  String? selectedBusinessType;
  String? selectedGovernorate;

  final List<String> syrianGovernorates = [
    "Damascus / دمشق",
    "Rif Dimashq / ريف دمشق",
    "Aleppo / حلب",
    "Homs / حمص",
    "Hama / حماة",
    "Lattakia / اللاذقية",
    "Tartus / طرطوس",
    "Idlib / إدلب",
    "Daraa / درعا",
    "As-Suwayda / السويداء",
    "Quneitra / القنيطرة",
    "Deir ez-Zor / دير الزور",
    "Al-Hasakah / الحسكة",
    "Ar-Raqqah / الرقة",
  ];

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
    otherBusinessTypeController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    try {
      if (selectedGovernorate == null) {
        showError("Please select a governorate first before Google Sign-In");
        return;
      }

      // تحقق من بيانات الشركة قبل البدء بجوجل
      if (selectedRole == "company") {
        if (selectedBusinessType == null ||
            (selectedBusinessType == "Other" && otherBusinessTypeController.text.isEmpty) ||
            commercialRegisterFile == null) {
          showError(
              "Please complete company details (Business Type & File) before Google Sign-In");
          return;
        }
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final FirebaseAuth auth = FirebaseAuth.instance;

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.signIn();
      } catch (e) {
        if (mounted) Navigator.pop(context);
        return;
      }

      if (googleUser == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 1. تسجيل الدخول في Firebase
      await auth.signInWithCredential(credential);

      // 2. الحصول على Firebase ID Token وإرساله للباك إند
      final firebaseIdToken = await auth.currentUser?.getIdToken();
      if (firebaseIdToken == null) {
        throw Exception("Failed to get Firebase ID token.");
      }

      final finalBusinessType = selectedRole == 'company'
          ? (selectedBusinessType == "Other"
              ? otherBusinessTypeController.text.trim()
              : selectedBusinessType)
          : null;

      final result = await AiApiService.googleLogin(
        idToken: firebaseIdToken,
        role: selectedRole,
        governorate: selectedGovernorate!,
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        businessType: finalBusinessType,
        commercialRegisterFile: selectedRole == 'company' ? commercialRegisterFile : null,
      );

      if (mounted) {
        Navigator.pop(context);
        // شركة جديدة عبر Google تحتاج موافقة الأدمن
        if (result['requires_approval'] == true) {
          _showApprovalDialog();
          return;
        }
        final userRole = result['user']?['role'] ?? selectedRole;
        if (userRole == 'company') {
          Navigator.pushReplacementNamed(context, '/companyDashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/userDashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        // تسجيل الخروج من Firebase إذا فشل الربط بالباك إند
        await FirebaseAuth.instance.signOut();
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
    if (selectedGovernorate == null) {
      showError("Please select a Syrian Governorate");
      return false;
    }
    if (!termsAccepted) {
      showError("Accept terms first");
      return false;
    }
    if (selectedRole == "company") {
      if (selectedBusinessType == null) {
        showError("Please select business type");
        return false;
      }
      if (selectedBusinessType == "Other" && otherBusinessTypeController.text.trim().isEmpty) {
        showError("Please specify your business type");
        return false;
      }
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

  void _showApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.hourglass_top_rounded,
                  color: Colors.orange.shade700, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Account Under Review",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              "Your company account has been created successfully! 🎉",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Your account is currently pending admin approval. "
                      "You will receive an email once your account is approved and you can start using the platform.",
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Got it, Back to Login",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
        ],
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
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedGovernorate,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  hintText: "Select Governorate / اختر المحافظة",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: syrianGovernorates.map((gov) {
                  return DropdownMenuItem(
                    value: gov,
                    child: Text(gov),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGovernorate = value;
                  });
                },
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
                      governorate: selectedGovernorate!,
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

                    if (mounted) {
                      // شركة جديدة تحتاج موافقة الأدمن — نعرض dialog توضيحي
                      if (result['requires_approval'] == true) {
                        _showApprovalDialog();
                        return;
                      }

                      // باقي الأدوار (job seeker) تروح مباشرة للـ dashboard
                      final role = result['user']?['role'] ?? selectedRole;
                      Navigator.pushReplacementNamed(
                        context,
                        role == "job" ? '/userDashboard' : '/companyDashboard',
                      );
                    }
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