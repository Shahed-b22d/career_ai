import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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

  // 🔥 رفع PDF
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

  // 🔥 إنشاء PDF
  Future generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                name.text,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(email.text),
              pw.Text(phone.text),

              pw.SizedBox(height: 20),
              pw.Text(
                "Summary",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(summary.text),

              pw.SizedBox(height: 15),
              pw.Text(
                "Skills",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(skills.text),

              pw.SizedBox(height: 15),
              pw.Text(
                "Experience",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(experience.text),

              pw.SizedBox(height: 15),
              pw.Text(
                "Education",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(education.text),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/cv.pdf");

    await file.writeAsBytes(await pdf.save());

    // 🔥 عرض / تحميل
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
        title: const Text("Upload CV"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔵 رفع PDF
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
                child: Column(
                  children: const [
                    Icon(Icons.upload_file, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      "Upload your CV (PDF)",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (pickedFile != null)
              Text("File selected ✅", style: TextStyle(color: Colors.green)),

            const SizedBox(height: 30),

            const Text(
              "Or Create Your CV ✨",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            TextField(controller: name, decoration: input("Full Name")),
            const SizedBox(height: 10),

            TextField(controller: email, decoration: input("Email")),
            const SizedBox(height: 10),

            TextField(controller: phone, decoration: input("Phone")),
            const SizedBox(height: 10),

            TextField(
              controller: summary,
              maxLines: 2,
              decoration: input("Professional Summary"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: skills,
              maxLines: 2,
              decoration: input("Skills (مثال: إدارة، تصميم...)"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: experience,
              maxLines: 2,
              decoration: input("Experience"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: education,
              maxLines: 2,
              decoration: input("Education"),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: generatePDF,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text("Generate CV PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
