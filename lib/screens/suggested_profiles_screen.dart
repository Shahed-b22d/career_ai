import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SuggestedProfilesScreen extends StatelessWidget {
  const SuggestedProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Suggested Profiles",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "All AI Matches across your jobs",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          _buildCandidateCard(context, "Sarah Jenkins", "Senior Flutter Dev", "98%"),
          _buildCandidateCard(context, "Ahmed Ali", "Backend Engineer", "94%"),
          _buildCandidateCard(context, "Emily Chen", "UI/UX Designer", "91%"),
          _buildCandidateCard(context, "Michael Scott", "Product Manager", "88%"),
          _buildCandidateCard(context, "John Doe", "Laravel Backend Dev", "85%"),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(BuildContext context, String name, String role, String matchScore) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/candidateProfile',
          arguments: {
            'name': name,
            'role': role,
            'match': matchScore,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.person, color: Colors.blue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.green, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    matchScore,
                    style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
