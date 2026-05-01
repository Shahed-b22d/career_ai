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
import 'cv_analysis_screen.dart';

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

  Future generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(name.text, style: pw.TextStyle(fontSize: 24)),
            pw.Text("${email.text} | ${phone.text}"),
            pw.Divider(),
            pw.Text(summary.text),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(
        title: const Text("Upload CV"),

        // 🔥 سهم رجوع أبيض
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [

            GestureDetector(
              onTap: pickPDF,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 10),
                    const Text("Upload CV"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            CustomInputField(hint: "Name", icon: Icons.person, controller: name),
            const SizedBox(height: 10),

            CustomInputField(hint: "Email", icon: Icons.email, controller: email),
            const SizedBox(height: 10),

            CustomInputField(hint: "Phone", icon: Icons.phone, controller: phone),
            const SizedBox(height: 10),

            _textArea("Summary", summary),
            _textArea("Skills", skills),
            _textArea("Experience", experience),
            _textArea("Education", education),

            const SizedBox(height: 20),

            CustomButton(
              text: "Analyze CV",
              onPressed: () async {

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const FancyLoader(),
                );

                await Future.delayed(const Duration(seconds: 6));

                if (mounted) Navigator.pop(context);

                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CvAnalysisScreen(),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _textArea(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// 🔥🔥🔥 LOADER احترافي جداً
//////////////////////////////////////////////////////////////////

class FancyLoader extends StatefulWidget {
  const FancyLoader({super.key});

  @override
  State<FancyLoader> createState() => _FancyLoaderState();
}

class _FancyLoaderState extends State<FancyLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  double progress = 0;

  final List<String> messages = [
    "Extracting Resume Data...",
    "Analyzing Skills & Experience...",
    "Matching with Job Market...",
    "Generating AI Insights..."
  ];

  int currentMessage = 0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(() {
        setState(() {
          progress = controller.value;

          if (progress > 0.75) {
            currentMessage = 3;
          } else if (progress > 0.5) {
            currentMessage = 2;
          } else if (progress > 0.25) {
            currentMessage = 1;
          } else {
            currentMessage = 0;
          }
        });
      });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.6), // 🔥 خلفية احترافية
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // 💎 دائرة Gradient مع أيقونة ذكاء اصطناعي في المنتصف
            Stack(
              alignment: Alignment.center,
              children: [
                // خلفية دائرية خفيفة
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                // المؤشر الدائري المتدرج
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const SweepGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                          AppTheme.primaryColor,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ).createShader(rect);
                    },
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
                // الأيقونة والنص في المنتصف
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ✨ نص متغير ناعم
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                messages[currentMessage],
                key: ValueKey(currentMessage),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none, // ❌ بدون خط أصفر
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "This will only take a moment",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}