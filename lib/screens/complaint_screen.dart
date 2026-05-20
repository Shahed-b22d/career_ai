import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import '../services/ai_api_service.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await AiApiService.submitComplaint(
        subject: subjectController.text,
        message: messageController.text,
      );

      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complaint submitted successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );
      
      if (mounted) Navigator.pop(context); // Go back after success

    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Complaints / الشكاوي", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Submit a Complaint",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please describe your issue below, and our support team will review it as soon as possible.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                CustomInputField(
                  hint: "Subject / الموضوع",
                  icon: Icons.subject,
                  controller: subjectController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please enter a subject";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: messageController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: "Message / الرسالة",
                    prefixIcon: const Icon(Icons.message_outlined, color: AppTheme.primaryColor),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please enter your message";
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                CustomButton(
                  text: "Submit",
                  onPressed: submitComplaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
