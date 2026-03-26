import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  InputDecoration input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Create CV"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickPDF,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.upload_file, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      "Upload CV (PDF)",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(controller: name, decoration: input("Full Name")),
            const SizedBox(height: 10),

            TextField(controller: email, decoration: input("Email")),
            const SizedBox(height: 10),

            TextField(controller: phone, decoration: input("Phone")),
            const SizedBox(height: 10),

            TextField(
              controller: summary,
              maxLines: 3,
              decoration: input("Write short intro about you"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: skills,
              maxLines: 2,
              decoration: input("Write your skills (e.g. teamwork, coding)"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: experience,
              maxLines: 3,
              decoration: input("Write your experience or projects"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: education,
              maxLines: 2,
              decoration: input("Your education"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: generatePDF,
              child: const Text("Generate CV"),
            ),
          ],
        ),
      ),
    );
  }
}
