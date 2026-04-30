import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen>
    with SingleTickerProviderStateMixin {
  final companyNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  String workType = "IT"; // ✅ نوع العمل

  final _formKey = GlobalKey<FormState>();

  File? image;

  late AnimationController _controller;
  late Animation<double> fade;
  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fade = Tween(begin: 0.0, end: 1.0).animate(_controller);
    slide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ModalRoute.of(context)!.settings.arguments as Map?;
      if (data != null) {
        companyNameController.text = data["name"] ?? "";
        emailController.text = data["email"] ?? "";
        phoneController.text = data["phone"] ?? "";
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    companyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  String? validateEmail(String? v) {
    if (v == null || v.isEmpty) return "Required";
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v)) {
      return "Invalid email";
    }
    return null;
  }

  String? validatePhone(String? v) {
    if (v == null || v.isEmpty) return "Required";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
      return "10 digits required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            children: [
              // 🔥 HEADER المحسن
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 40),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.backgroundColor,
                            backgroundImage: image != null ? FileImage(image!) : null,
                            child: image == null
                                ? const Icon(Icons.business_rounded, size: 50, color: AppTheme.textSecondaryColor)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Company Profile",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 FORM
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          CustomInputField(
                            hint: "Company Name",
                            icon: Icons.business_outlined,
                            controller: companyNameController,
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            hint: "Email",
                            icon: Icons.email_outlined,
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                          ),
                          const SizedBox(height: 16),

                          CustomInputField(
                            hint: "Phone",
                            icon: Icons.phone_outlined,
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            validator: validatePhone,
                          ),
                          const SizedBox(height: 16),

                          // ✅ نوع العمل
                          DropdownButtonFormField<String>(
                            value: workType,
                            dropdownColor: AppTheme.cardColor,
                            decoration: InputDecoration(
                              hintText: "Work Type",
                              prefixIcon: const Icon(Icons.work_outline, color: AppTheme.primaryColor),
                              filled: true,
                              fillColor: AppTheme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: ["IT", "Medical", "Engineering", "Other"]
                                .map(
                                  (e) => DropdownMenuItem(value: e, child: Text(e)),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                if (v != null) workType = v;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Company Description",
                              prefixIcon: const Icon(Icons.description_outlined, color: AppTheme.primaryColor),
                              filled: true,
                              fillColor: AppTheme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 40),

                          CustomButton(
                            text: "Save Changes",
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Profile updated successfully ✅"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
