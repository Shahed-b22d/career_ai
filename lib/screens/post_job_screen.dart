import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/ai_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_input_field.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final salaryController = TextEditingController();
  final locationController = TextEditingController();
  final descController = TextEditingController();
  final reqController = TextEditingController();

  String jobType = "Full-time";

  @override
  void dispose() {
    titleController.dispose();
    salaryController.dispose();
    locationController.dispose();
    descController.dispose();
    reqController.dispose();
    super.dispose();
  }

  // 🔹 دالة الدفع ورفع الوظيفة عبر الباك-إند
  void handleStripePaymentAndPostJob() async {
    if (!_formKey.currentState!.validate()) return;
    
    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
    );

    // استدعاء الباك-إند لإنشاء الوظيفة والحصول على رابط دفع Stripe
    final response = await AiApiService.createJobAndGetCheckoutUrl(
      title: titleController.text,
      jobType: jobType,
      location: locationController.text,
      salary: salaryController.text,
      description: descController.text,
      requirements: reqController.text,
    );

    if (!mounted) return;
    Navigator.pop(context); // إخفاء مؤشر التحميل

    if (response != null && response['success'] == true && response['checkout_url'] != null) {
      final checkoutUrl = response['checkout_url'] as String;
      final uri = Uri.parse(checkoutUrl);
      
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        // إظهار تنبيه للمستخدم لإعلامه بالدفع في المتصفح والعودة للتطبيق
        if (mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.payment_rounded, color: AppTheme.primaryColor, size: 30),
                  SizedBox(width: 10),
                  Text("Pay in Browser", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text("Stripe checkout has opened in your browser. Please complete payment there. Once completed, your job post will be published automatically!"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context); // العودة للشاشة السابقة
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Done / Back to Dashboard", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch payment page: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.orange, size: 28),
                SizedBox(width: 10),
                Text("Not Published", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              "Your job post was saved but will not be published until payment is completed.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Post a Job"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
                const Text(
                  "Reach Top Talent",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Fill in the details below to publish your opening.",
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
                const SizedBox(height: 30),

                // المسمى الوظيفي
                CustomInputField(
                  hint: "Job Title (e.g. Senior Flutter Developer)",
                  icon: Icons.title_rounded,
                  controller: titleController,
                  validator: (v) => v!.isEmpty ? "Job Title is required" : null,
                ),
                const SizedBox(height: 16),

                // نوع العمل
                DropdownButtonFormField<String>(
                  initialValue: jobType,
                  dropdownColor: AppTheme.cardColor,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.work_outline_rounded, color: AppTheme.primaryColor),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ["Full-time", "Part-time", "Contract", "Remote", "Freelance"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setState(() { if (v != null) jobType = v; });
                  },
                ),
                const SizedBox(height: 16),

                // الموقع والراتب
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        hint: "Location",
                        icon: Icons.location_on_outlined,
                        controller: locationController,
                        validator: (v) => v!.isEmpty ? "*" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomInputField(
                        hint: "Salary",
                        icon: Icons.attach_money_rounded,
                        controller: salaryController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? "*" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // تفاصيل الوظيفة
                TextFormField(
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Job Description...",
                    prefixIcon: const Icon(Icons.description_outlined, color: AppTheme.primaryColor),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),

                // المتطلبات
                TextFormField(
                  controller: reqController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Requirements & Skills...",
                    prefixIcon: const Icon(Icons.checklist_rtl_rounded, color: AppTheme.primaryColor),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 40),

                // الدفع والنشر
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: handleStripePaymentAndPostJob,
                    icon: const Icon(Icons.payment_rounded, color: Colors.white),
                    label: const Text(
                      "Post & Pay",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
