import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/ai_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import 'cv_analysis_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // 0 = Upload PDF,  1 = Manual Entry
  int _selectedMode = 0;
  File? pickedFile;

  final targetJob    = TextEditingController();
  final name         = TextEditingController();
  final email        = TextEditingController();
  final phone        = TextEditingController();
  final summary      = TextEditingController();
  final skills       = TextEditingController();
  final experience   = TextEditingController();
  final education    = TextEditingController();

  @override
  void dispose() {
    targetJob.dispose(); name.dispose(); email.dispose();
    phone.dispose(); summary.dispose(); skills.dispose();
    experience.dispose(); education.dispose();
    super.dispose();
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() => pickedFile = File(result.files.single.path!));
    }
  }

  Future<void> _analyzeCV() async {
    if (targetJob.text.trim().isEmpty) {
      _snack('Please enter a Target Job first');
      return;
    }

    if (_selectedMode == 0) {
      // PDF mode
      if (pickedFile == null) { _snack('Please upload a PDF first'); return; }
      if (!await pickedFile!.exists()) { _snack('File not found'); return; }
    } else {
      // Manual mode
      if (summary.text.trim().isEmpty && skills.text.trim().isEmpty &&
          experience.text.trim().isEmpty && education.text.trim().isEmpty) {
        _snack('Please fill in at least one field');
        return;
      }
    }

    if (!mounted) return;
    showDialog(context: context, barrierDismissible: false,
        builder: (_) => const FancyLoader());

    final manualText = _selectedMode == 1
        ? "Summary: ${summary.text}\nSkills: ${skills.text}\n"
          "Experience: ${experience.text}\nEducation: ${education.text}"
        : "";

    final response = await AiApiService.analyzeGap(
      targetJob.text,
      manualText,
      cvFile: _selectedMode == 0 ? pickedFile : null,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (response != null) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => CvAnalysisScreen(
          analysisData: response,
          targetJob: targetJob.text,
          userDataText: manualText.isNotEmpty ? manualText : (response['cv_text'] ?? ""),
        ),
      ));
    } else {
      _snack('Failed to analyze CV');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Analyze Your CV"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Target Job (always visible) ──────────────────────────────
            CustomInputField(
              hint: "Target Job (e.g. Flutter Developer)",
              icon: Icons.work_outline,
              controller: targetJob,
            ),
            const SizedBox(height: 24),

            // ── Mode Toggle ──────────────────────────────────────────────
            const Text(
              "How would you like to proceed?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _modeTab(0, Icons.upload_file_rounded, "Upload CV\n(PDF)"),
                  _modeTab(1, Icons.edit_note_rounded,   "Enter\nManually"),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Panel ────────────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: _selectedMode == 0
                  ? _buildUploadPanel()
                  : _buildManualPanel(),
            ),

            const SizedBox(height: 32),

            // ── Analyze Button ───────────────────────────────────────────
            CustomButton(text: "Analyze with AI ✨", onPressed: _analyzeCV),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Mode toggle tab
  Widget _modeTab(int index, IconData icon, String label) {
    final selected = _selectedMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.25),
                    blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PDF Upload Panel
  Widget _buildUploadPanel() {
    return GestureDetector(
      key: const ValueKey('upload'),
      onTap: _pickPDF,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: pickedFile != null
                ? Colors.green.shade400
                : AppTheme.primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03),
                blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          children: [
            Icon(
              pickedFile != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
              size: 64,
              color: pickedFile != null ? Colors.green : AppTheme.primaryColor,
            ),
            const SizedBox(height: 14),
            Text(
              pickedFile != null ? "File ready!" : "Tap to upload your CV",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: pickedFile != null ? Colors.green : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            if (pickedFile != null) ...[
              Text(
                pickedFile!.path.split('\\').last.split('/').last,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _pickPDF,
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text("Change file"),
              )
            ] else
              const Text(
                "PDF format only",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  // ── Manual Entry Panel
  Widget _buildManualPanel() {
    return Column(
      key: const ValueKey('manual'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard("👤 Personal Info", [
          _field("Name", Icons.person_outline, name),
          _field("Email", Icons.email_outlined, email),
          _field("Phone", Icons.phone_outlined, phone),
        ]),
        const SizedBox(height: 16),
        _sectionCard("📝 Professional Details", [
          _area("Professional Summary", summary),
          _area("Skills (comma-separated)", skills),
          _area("Work Experience", experience),
          _area("Education", education),
        ]),
      ],
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String hint, IconData icon, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
          filled: true,
          fillColor: AppTheme.backgroundColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _area(String hint, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppTheme.backgroundColor,
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
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
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Stack(
              alignment: Alignment.center,
              children: [
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

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                messages[currentMessage],
                key: ValueKey(currentMessage),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
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
