import 'package:flutter/material.dart';

class UploadCVScreen extends StatefulWidget {
  const UploadCVScreen({super.key});

  @override
  State<UploadCVScreen> createState() => _UploadCVScreenState();
}

class _UploadCVScreenState extends State<UploadCVScreen>
    with SingleTickerProviderStateMixin {
  bool showForm = false;

  final nameController = TextEditingController();
  final jobController = TextEditingController();
  final skillsController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    jobController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Upload CV"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: showForm ? buildForm() : buildOptions(),
        ),
      ),
    );
  }

  // 🔥 الخيارات
  Widget buildOptions() {
    return Column(
      key: const ValueKey("options"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        optionButton(
          icon: Icons.upload_file,
          text: "Upload CV",
          onTap: () {
            // 🔥 لاحقاً file picker
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("CV Uploaded ✅")));

            Navigator.pop(context, true);
          },
        ),

        const SizedBox(height: 20),

        optionButton(
          icon: Icons.edit_document,
          text: "Create CV",
          onTap: () {
            setState(() {
              showForm = true;
            });
            _controller.forward();
          },
        ),
      ],
    );
  }

  // 🔥 زر ستايل المشروع
  Widget optionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 الفورم
  Widget buildForm() {
    return FadeTransition(
      opacity: fade,
      child: Column(
        key: const ValueKey("form"),
        children: [
          TextField(
            controller: nameController,
            decoration: input("Full Name", Icons.person),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: jobController,
            decoration: input("Job Title", Icons.work),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: skillsController,
            decoration: input("Skills", Icons.star),
          ),

          const SizedBox(height: 25),

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
                // 🔥 لاحقاً نولد CV
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("CV Created ✅")));

                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text("Generate CV"),
            ),
          ),

          const SizedBox(height: 15),

          TextButton(
            onPressed: () {
              setState(() {
                showForm = false;
              });
            },
            child: const Text("Back"),
          ),
        ],
      ),
    );
  }

  InputDecoration input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}
