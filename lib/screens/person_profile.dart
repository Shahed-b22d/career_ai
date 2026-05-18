import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/locale_provider.dart';
import '../services/ai_api_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';

class PersonProfile extends StatefulWidget {
  const PersonProfile({super.key});

  @override
  State<PersonProfile> createState() => _PersonProfileState();
}

class _PersonProfileState extends State<PersonProfile>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String currentRole = "job";
  String? selectedRegion;
  String? savedBusinessType;

  File? _image;

  late AnimationController _controller;
  late Animation<double> fade;
  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    fade = Tween(begin: 0.0, end: 1.0).animate(_controller);
    slide = Tween(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await LocalStorageService.getUserProfile();
    setState(() {
      nameController.text = profile['name'] ?? "";
      emailController.text = profile['email'] ?? "";
      phoneController.text = profile['phone'] ?? "";
      currentRole = profile['role'] ?? "job";
      selectedRegion = profile['region'];
      savedBusinessType = profile['businessType'];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            children: [

              // 🔥 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          // Language toggle
                          TextButton(
                            onPressed: () {
                              final provider = LocaleProvider.of(context);
                              final next = provider.locale == 'en' ? 'ar' : 'en';
                              provider.setLocale(next);
                            },
                            child: Text(
                              LocaleProvider.of(context).locale == 'en' ? 'AR' : 'EN',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 46,
                            backgroundImage:
                                _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      L(context, 'edit_profile'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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

                          CustomInputField(
                            hint: L(context, 'full_name'),
                            icon: Icons.person_outline,
                            controller: nameController,
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Required";
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          CustomInputField(
                            hint: L(context, 'email'),
                            icon: Icons.email_outlined,
                            controller: emailController,
                            validator: (v) =>
                                !isValidEmail(v!) ? "Invalid email" : null,
                          ),

                          const SizedBox(height: 16),

                          CustomInputField(
                            hint: L(context, 'phone'),
                            icon: Icons.phone_outlined,
                            controller: phoneController,
                            validator: (v) =>
                                !isValidPhone(v!) ? "Invalid phone" : null,
                          ),

                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedRegion,
                            decoration: InputDecoration(
                              hintText: L(context, 'select_region'),
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            items: [
                              "Damascus",
                              "Rif Dimashq",
                              "Aleppo",
                              "Homs",
                              "Hama",
                              "Latakia",
                              "Tartus",
                              "Idlib",
                              "Raqqa",
                              "Al-Hasakah",
                              "Deir ez-Zor",
                              "As-Suwayda",
                              "Daraa",
                              "Quneitra",
                            ]
                                .map((region) => DropdownMenuItem(
                                      value: region,
                                      child: Text(region),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedRegion = value;
                              });
                            },
                          ),

                          const SizedBox(height: 30),

                          // 🔥 SAVE
                          CustomButton(
                            text: L(context, 'save_changes'),
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;

                              LocalStorageService.saveUserProfile(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                role: currentRole,
                                phone: phoneController.text.trim(),
                                region: selectedRegion,
                                businessType: savedBusinessType,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(L(context, 'saved_success')),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // 🔥 LOGOUT
                          OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text("Logout"),
                                  content: const Text(
                                      "Are you sure you want to logout?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await AiApiService.logout();
                                        if (mounted) {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/login',
                                            (route) => false,
                                          );
                                        }
                                      },

                                      child: const Text("Logout"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize:
                                  const Size(double.infinity, 55),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),

                          const SizedBox(height: 80),
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