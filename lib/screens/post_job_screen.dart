import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
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

  // 🔹 دالة الدفع الوهمية بـ Stripe لحين ربط الباك-إند
  void handleStripePaymentAndPostJob() {
    if (!_formKey.currentState!.validate()) return;
    
    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    // إظهار نافذة الدفع
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStripeMockupSheet(),
    );
    
    // الكود الحقيقي الخاص بـ Stripe متواجد بالأسفل:
    /*
    try {
      // 1. جلب PaymentIntent (Client Secret) من السيرفر الخاص بك (Laravel/NodeJs)
      // final response = await http.post("YOUR_API_URL/create-payment-intent", body: {'amount': 2500, 'currency': 'usd'});
      // final clientSecret = jsonDecode(response.body)['clientSecret'];

      // 2. إعداد شاشة Stripe
      // await Stripe.instance.initPaymentSheet(
      //   paymentSheetParameters: SetupPaymentSheetParameters(
      //     paymentIntentClientSecret: clientSecret,
      //     merchantDisplayName: 'CareerAI Inc.',
      //   ),
      // );

      // 3. إظهار الدفع
      // await Stripe.instance.presentPaymentSheet();

      // 4. بعد النجاح، رفع الوظيفة
      // postJobToDatabase();
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Job Posted Successfully! ✅")));
      
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed: $e")));
    }
    */
  }

  Widget _buildStripeMockupSheet() {
    return Container(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stripe Checkout",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 20,
                  color: const Color(0xFF635BFF), // لون سترايب مميز
                ),
              ),
              const Icon(Icons.close_rounded, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Pay to publish your job listing immediately.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          
          // حقل بطاقة وهمي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card_rounded, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Card information",
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text("\$25.00", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // إغلاق نافذة الدفع

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                );

                await Future.delayed(const Duration(seconds: 2));

                if (mounted) {
                  Navigator.pop(context); // إغلاق دائرة التحميل
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Payment Successful! Job Published ✅"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // العودة لملف الشركة
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF635BFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Pay \$25.00 & Post Job", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
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
                  value: jobType,
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
                      "Pay \$25.00 via Stripe & Post",
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
