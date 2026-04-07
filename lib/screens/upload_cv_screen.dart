import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? pickedFile;

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final summary = TextEditingController();
  final skills = TextEditingController();
  final experience = TextEditingController();
  final education = TextEditingController();

  // 🔐 API KEY من run
  final String apiKey = const String.fromEnvironment('OPENAI_API_KEY');

  // 📥 رفع PDF
  Future pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        pickedFile = File(result.files.single.path!);
      });
    }
  }

  // 🤖 تحسين AI
  Future improveWithAI() async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": "You are a professional ATS CV writer.",
          },
          {
            "role": "user",
            "content":
                """
Improve this CV and return JSON only:

{
"summary": "...",
"skills": "...",
"experience": "...",
"education": "..."
}

Summary: ${summary.text}
Skills: ${skills.text}
Experience: ${experience.text}
Education: ${education.text}
""",
          },
        ],
      }),
    );

    print(response.body);

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("API Error ❌")));
      return;
    }

    final data = jsonDecode(response.body);
    final aiText = data["choices"][0]["message"]["content"];

    final jsonData = jsonDecode(aiText);

    setState(() {
      summary.text = jsonData["summary"];
      skills.text = jsonData["skills"];
      experience.text = jsonData["experience"];
      education.text = jsonData["education"];
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Improved Successfully ✅")));
  }

  // 📄 PDF
  Future generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                name.text,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text("${email.text} | ${phone.text}"),
              pw.Divider(),

              pw.Text(
                "SUMMARY",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(summary.text),

              pw.SizedBox(height: 10),
              pw.Text(
                "SKILLS",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(skills.text),

              pw.SizedBox(height: 10),
              pw.Text(
                "EXPERIENCE",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(experience.text),

              pw.SizedBox(height: 10),
              pw.Text(
                "EDUCATION",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(education.text),
            ],
          ),
        ),
      ),
    );

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Your CV is ready 🎉"),

              ElevatedButton(
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (format) async => pdf.save(),
                  );
                },
                child: const Text("Download CV"),
              ),

              OutlinedButton(
                onPressed: () async {
                  await improveWithAI();
                  Navigator.pop(context);
                },
                child: const Text("✨ Improve with AI"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text("Create CV"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
=======
        title: const Text("Upload CV"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
>>>>>>> 50c5dd8 (feat: complete UI redesign, modern theme, add forgot password and post job screens)
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pickPDF,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: pickedFile != null ? Colors.green : AppTheme.primaryColor.withOpacity(0.5),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
<<<<<<< HEAD
                child: const Column(
                  children: [
                    Icon(Icons.upload_file, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      "Upload CV (PDF)",
                      style: TextStyle(color: Colors.white),
=======
                child: Column(
                  children: [
                    Icon(
                      pickedFile != null ? Icons.check_circle_rounded : Icons.file_upload_outlined,
                      color: pickedFile != null ? Colors.green : AppTheme.primaryColor,
                      size: 60,
>>>>>>> 50c5dd8 (feat: complete UI redesign, modern theme, add forgot password and post job screens)
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pickedFile != null ? "File selected successfully" : "Upload your CV (PDF)",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 18,
                        color: pickedFile != null ? Colors.green : AppTheme.textPrimaryColor,
                      ),
                    ),
                    if (pickedFile == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Tap to browse files",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ]
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

<<<<<<< HEAD
            TextField(controller: name, decoration: input("Full Name")),
            const SizedBox(height: 10),

            TextField(controller: email, decoration: input("Email")),
            const SizedBox(height: 10),

            TextField(controller: phone, decoration: input("Phone")),
            const SizedBox(height: 10),
=======
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Or Create Manually",
                    style: TextStyle(color: AppTheme.textSecondaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),

            const SizedBox(height: 30),

            CustomInputField(hint: "Full Name", icon: Icons.person_outline, controller: name),
            const SizedBox(height: 16),

            CustomInputField(hint: "Email", icon: Icons.email_outlined, controller: email),
            const SizedBox(height: 16),

            CustomInputField(hint: "Phone", icon: Icons.phone_outlined, controller: phone),
            const SizedBox(height: 16),
>>>>>>> 50c5dd8 (feat: complete UI redesign, modern theme, add forgot password and post job screens)

            TextField(
              controller: summary,
              maxLines: 3,
<<<<<<< HEAD
              decoration: input("Write short intro about you"),
=======
              decoration: const InputDecoration().copyWith(
                hintText: "Professional Summary",
                prefixIcon: const Icon(Icons.description_outlined, color: AppTheme.primaryColor),
              ),
>>>>>>> 50c5dd8 (feat: complete UI redesign, modern theme, add forgot password and post job screens)
            ),
            const SizedBox(height: 16),

            TextField(
              controller: skills,
<<<<<<< HEAD
              maxLines: 2,
              decoration: input("Write your skills (e.g. teamwork, coding)"),
=======
              maxLines: 3,
              decoration: const InputDecoration().copyWith(
                hintText: "Skills (e.g. Management, Design...)",
                prefixIcon: const Icon(Icons.star_outline_rounded, color: AppTheme.primaryColor),
              ),
>>>>>>> 50c5dd8 (feat: complete UI redesign, modern theme, add forgot password and post job screens)
            ),
            const SizedBox(height: 16),

            TextField(
              controller: experience,
              maxLines: 3,
<<<<<<< HEAD
              decoration: input("Write your experience or projects"),
=======
              decoration: const InputDecoration().copyWith(
                hintText: "Experience",
                prefixIcon: const Icon(Icons.work_outline_rounded, color: AppTheme.primaryColor),
              ),
>>>>>>> 50c5dd8 (feat: complete UI redesign, modern theme, add forgot password and post job screens)
            ),
            const SizedBox(height: 16),

            TextField(
              controller: education,
<<<<<<< HEAD
              maxLines: 2,
              decoration: input("Your education"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: generatePDF,
              child: const Text("Generate CV"),
=======
              maxLines: 3,
              decoration: const InputDecoration().copyWith(
                hintText: "Education",
                prefixIcon: const Icon(Icons.school_outlined, color: AppTheme.primaryColor),
              ),
>>>>>>> 50c5dd8 (feat: complete UI redesign, modern theme, add forgot password and post job screens)
            ),

            const SizedBox(height: 35),

            CustomButton(
              text: "Generate CV PDF",
              onPressed: generatePDF,
            ),
            
            const SizedBox(height: 100), // padding for bottom nav space
          ],
        ),
      ),
    );
  }
}
