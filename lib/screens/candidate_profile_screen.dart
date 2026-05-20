import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  bool isShortlisted = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final name = args?['name'] ?? 'Candidate Name';
    final role = args?['role'] ?? 'Role title';
    final matchScore = args?['match'] ?? '90%';
    final email = args?['email'] ?? 'No email provided';
    final phone = args?['phone'] ?? 'No phone provided';
    final governorate = args?['governorate'] ?? 'Not specified';
    final List<dynamic> skills = args?['skills'] ?? [];
    final List<dynamic> missingSkills = args?['missing_skills'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Candidate Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(name, role, matchScore),
            const SizedBox(height: 32),
            _buildMatchDetails(skills, missingSkills),
            const SizedBox(height: 40),
            CustomButton(
              text: "Shortlist Candidate",
              onPressed: () {
                _showContactInfoSheet(context, name, email, phone, governorate);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactInfoSheet(BuildContext context, String name, String email, String phone, String governorate) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "$name Shortlisted!",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "You can now contact this candidate directly.",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email_outlined, "Email", email),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.phone_android_outlined, "Phone", phone),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.location_on_outlined, "Governorate", governorate),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: "Close",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(String name, String role, String matchScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.person, color: Colors.blue, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  "AI Match: $matchScore",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchDetails(List<dynamic> skills, List<dynamic> missingSkills) {
    final List<Widget> matchedWidgets = [];
    final List<Widget> missingWidgets = [];

    for (var s in skills) {
      matchedWidgets.add(_buildSkillMatchRow(s.toString(), true));
    }

    for (var ms in missingSkills) {
      missingWidgets.add(_buildSkillMatchRow(ms.toString(), false));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "AI Gap Analysis (Skills & Gaps)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (matchedWidgets.isEmpty && missingWidgets.isEmpty)
          const Text(
            "No skills data was extracted from the resume.",
            style: TextStyle(
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          )
        else ...[
          if (matchedWidgets.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text(
                "Candidate Strengths / Current Skills",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
            ),
            ...matchedWidgets,
            const SizedBox(height: 16),
          ],
          if (missingWidgets.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text(
                "Missing Skills / Gap Areas",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
            ...missingWidgets,
          ],
        ],
      ],
    );
  }

  Widget _buildSkillMatchRow(String skill, bool isMatched) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isMatched ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMatched ? Icons.check_circle : Icons.cancel,
            color: isMatched ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              skill,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            isMatched ? "Possessed" : "Missing",
            style: TextStyle(
              fontSize: 13,
              color: isMatched ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
