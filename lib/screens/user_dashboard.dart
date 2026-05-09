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

  // 🔹 Skills Progress (Dynamic)
  Widget _buildSkillsProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Skills Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...acquiredSkills.map((skill) => _skill(skill, 1.0, Colors.green)), // Acquired at 100%
        ...missingSkills.map((skill) => _skill(skill, 0.2, AppTheme.primaryColor)), // Missing at 20%
      ],
    );
  }

  Widget _skill(String name, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text("${(progress * 100).toInt()}%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
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