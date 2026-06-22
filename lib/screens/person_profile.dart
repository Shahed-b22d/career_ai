import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import '../services/ai_api_service.dart';
import '../services/local_storage_service.dart';
import 'complaint_screen.dart';

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
      selectedGovernorate = profile['governorate'];
      if (selectedGovernorate != null && !syrianGovernorates.contains(selectedGovernorate)) {
        selectedGovernorate = null;
      }
      avatarUrl = profile['avatar'];
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
                            onSelected: (value) async {
                              if (value == "logout") {
                                await logout();
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
                              radius: 46,
                              backgroundImage: _image != null
                                  ? FileImage(_image!) as ImageProvider
                                  : (avatarUrl != null ? NetworkImage("http://127.0.0.1:8000/storage/$avatarUrl") : null),
                              child: (_image == null && avatarUrl == null)
                                  ? const Icon(Icons.person, size: 40)
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

                    const Text(
                      "Edit Profile",
                      style: TextStyle(
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
                            hint: "Full Name",
                            icon: Icons.person_outline,
                            controller: nameController,
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Required";
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          CustomInputField(
                            hint: "Email",
                            icon: Icons.email_outlined,
                            controller: emailController,
                            validator: (v) =>
                                !isValidEmail(v!) ? "Invalid email" : null,
                          ),

                          const SizedBox(height: 16),

                          CustomInputField(
                            hint: "Phone",
                            icon: Icons.phone_outlined,
                            controller: phoneController,
                            validator: (v) =>
                                !isValidPhone(v!) ? "Invalid phone" : null,
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

                          const SizedBox(height: 30),

                          // 🔥 SAVE
                          CustomButton(
                            text: "Save Changes",
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

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
                                  avatarFile: _image,
                                );
                                if (mounted) Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Saved successfully ✅"),
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

                          const SizedBox(height: 16),

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