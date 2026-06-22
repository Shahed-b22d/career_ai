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
  List<dynamic> _myComplaints = [];
  bool _loadingList = true;

  @override
  void initState() {
    super.initState();
    _loadMyComplaints();
  }

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMyComplaints() async {
    setState(() => _loadingList = true);
    _myComplaints = await AiApiService.getMyComplaints();
    if (mounted) setState(() => _loadingList = false);
  }

  Color _statusColor(String status) {
    if (status == 'resolved') return Colors.green;
    if (status == 'in_progress') return Colors.blue;
    return Colors.orange;
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
      subjectController.clear();
      messageController.clear();
      await _loadMyComplaints();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint submitted successfully ✅"), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Complaints", style: TextStyle(color: Colors.black87)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Submit a Complaint", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "Describe your issue. Our team will review and respond.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomInputField(
                      hint: "Subject ",
                      icon: Icons.subject,
                      controller: subjectController,
                      validator: (v) => (v == null || v.isEmpty) ? "Please enter a subject" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Message ",
                        prefixIcon: const Icon(Icons.message_outlined, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: AppTheme.cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? "Please enter your message" : null,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(text: "Submit", onPressed: submitComplaint),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text("My Complaints", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_loadingList)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (_myComplaints.isEmpty)
                const Text("No complaints yet", style: TextStyle(color: Colors.grey))
              else
                ..._myComplaints.map((c) => _complaintTile(c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _complaintTile(Map<String, dynamic> c) {
    final status = c['status'] ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(c['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(c['created_at'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          if (c['admin_response'] != null && (c['admin_response'] as String).isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text("Admin reply:", style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor, fontSize: 13)),
            const SizedBox(height: 4),
            Text(c['admin_response'], style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
