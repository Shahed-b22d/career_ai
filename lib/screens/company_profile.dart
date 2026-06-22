import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ai_api_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import 'complaint_screen.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

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

  String workType = "IT";

  File? _image;
  String? avatarUrl;

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
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await LocalStorageService.getUserProfile();
    setState(() {
      nameController.text = profile['name'] ?? "";
      emailController.text = profile['email'] ?? "";
      phoneController.text = profile['phone'] ?? "";
      workType = profile['businessType'] ?? "IT";
      selectedGovernorate = profile['governorate'];
      if (selectedGovernorate != null && !syrianGovernorates.contains(selectedGovernorate)) {
        selectedGovernorate = null;
      }
      descriptionController.text = profile['description'] ?? "";
      avatarUrl = profile['avatar'];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
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

  Future<void> logout() async {
    await AiApiService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
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

              /// 🔥 HEADER (نفس اليوزر)
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

                    /// 🔥 Top Row (Back)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /// ⬅️ Back
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 🖼️ Avatar
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: PopupMenuButton<String>(
                            offset: const Offset(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: "edit",
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 10),
                                    Text("Edit Profile"),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: "complaints",
                                child: Row(
                                  children: [
                                    Icon(Icons.report_problem, color: Colors.orange),
                                    SizedBox(width: 10),
                                    Text("Complaints "),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: "logout",
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text("Logout"),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == "logout") {
                                logout();
                              } else if (value == "complaints") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ComplaintScreen()),
                                );
                              } else if (value == "edit") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("You are already in edit mode! / أنت في وضع التعديل بالفعل")),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: AppTheme.backgroundColor,
                              backgroundImage: _image != null
                                  ? FileImage(_image!) as ImageProvider
                                  : (avatarUrl != null ? NetworkImage("http://127.0.0.1:8000/storage/$avatarUrl") : null),
                              child: (_image == null && avatarUrl == null)
                                  ? const Icon(Icons.business, size: 50, color: AppTheme.textSecondaryColor)
                                  : null,
                            ),
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
                                Icons.camera_alt,
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

              /// 🔥 FORM
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          CustomInputField(
                            hint: "Company Name",
                            icon: Icons.business_outlined,
                            controller: nameController,
                          ),

                          const SizedBox(height: 16),

                          CustomInputField(
                            hint: "Email",
                            icon: Icons.email_outlined,
                            controller: emailController,
                          ),

                          const SizedBox(height: 16),

                          CustomInputField(
                            hint: "Phone",
                            icon: Icons.phone_outlined,
                            controller: phoneController,
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value: selectedGovernorate,
                            decoration: InputDecoration(
                              hintText: "Governorate ",
                              prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                              filled: true,
                              fillColor: AppTheme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
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

                          const SizedBox(height: 16),

                          /// 🔥 Dropdown أنيق
                          DropdownButtonFormField<String>(
                            value: workType,
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
                            items: ["IT", "Medical", "Engineering", "Other", if (!["IT", "Medical", "Engineering", "Other"].contains(workType)) workType]
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                workType = v!;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          TextField(
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
                          ),

                          const SizedBox(height: 40),

                          CustomButton(
                            text: "Save Changes",
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator()),
                              );

                              try {
                                await AiApiService.updateProfile(
                                  name: nameController.text,
                                  email: emailController.text,
                                  phone: phoneController.text,
                                  governorate: selectedGovernorate,
                                  businessType: workType,
                                  description: descriptionController.text,
                                  avatarFile: _image,
                                );
                                if (mounted) Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Updated Successfully ✅"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                if (mounted) Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
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