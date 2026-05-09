import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/local_storage_service.dart';
import 'roadmap_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  double matchScore = 0.0;
  List<String> acquiredSkills = [];
  List<String> missingSkills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await LocalStorageService.getAnalysisData();
    setState(() {
      matchScore = data['matchScore'] ?? 0.0;
      acquiredSkills = data['acquiredSkills'] ?? [];
      missingSkills = data['missingSkills'] ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildAiInsight(context),
                    const SizedBox(height: 24),
                    _buildStats(context),
                    const SizedBox(height: 32),
                    if (acquiredSkills.isNotEmpty || missingSkills.isNotEmpty)
                      _buildSkillsProgress(),
                    const SizedBox(height: 32),
                    if (missingSkills.isNotEmpty)
                      _buildRoadmapSection(context),
                    const SizedBox(height: 32),
                    _buildActions(context),
                  ],
                ),
              ),
      ),
    );
  }

  // 🔹 Header
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome back 👋", style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              "Career Trainee",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/personProfile');
          },
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.person, color: Colors.blue),
          ),
        )
      ],
    );
  }

  // 🔹 AI Insight (Dynamic)
  Widget _buildAiInsight(BuildContext context) {
    String message = "Upload a CV to let AI analyze your career path 🚀";
    if (missingSkills.isNotEmpty) {
      message = "AI suggests improving: ${missingSkills.take(2).join(', ')} 🔥";
    } else if (acquiredSkills.isNotEmpty) {
      message = "You have all the required skills! Generate your ATS CV now 🌟";
    }

    return GestureDetector(
      onTap: () {
        if (missingSkills.isNotEmpty) {
           // Go to roadmap
        } else {
           Navigator.pushNamed(context, '/uploadCV');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0052FF), Color(0xFF6B00FF)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
          ],
        ),
      ),
    );
  }

  // 🔹 Stats (Dynamic)
  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        _card("Match Score", "${(matchScore * 100).toInt()}%", Icons.analytics, Colors.blue),
        const SizedBox(width: 16),
        _card("Acquired Skills", "${acquiredSkills.length}", Icons.verified, Colors.green),
      ],
    );
  }

  Widget _card(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
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
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // 🔹 Skills Progress (Dynamic & Redesigned 🔥)
  Widget _buildSkillsProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (acquiredSkills.isNotEmpty) ...[
          const Text("Acquired Skills", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: acquiredSkills.map((skill) => Chip(
              label: Text(skill, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
              backgroundColor: Colors.green.shade50,
              side: BorderSide(color: Colors.green.shade200),
              avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (missingSkills.isNotEmpty) ...[
          const Text("Skills to Master", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...missingSkills.map((skill) => _missingSkillCard(skill)),
        ]
      ],
    );
  }

  Widget _missingSkillCard(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_clock_outlined, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              "Pending",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Roadmap
  Widget _buildRoadmapSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Roadmap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              const Icon(Icons.map, color: Colors.blue),
              const SizedBox(width: 12),
              const Expanded(child: Text("Continue your learning roadmap")),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RoadmapScreen(
                      targetJob: "Target Role", // Could be saved locally if needed
                      missingSkills: missingSkills,
                    )),
                  );
                },
              )
            ],
          ),
        )
      ],
    );
  }

  // 🔹 Actions
  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _actionButton("Upload New CV", Icons.upload, () {
          Navigator.pushNamed(context, '/uploadCV');
        }),
      ],
    );
  }

  Widget _actionButton(String text, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: const Color(0xFF0052FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}