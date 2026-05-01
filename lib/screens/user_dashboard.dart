import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
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
              _buildSkillsProgress(),
              const SizedBox(height: 32),
              _buildRoadmapSection(context),
              const SizedBox(height: 32),
              _buildRecentActivity(),
              const SizedBox(height: 32),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Header (محسّن)
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome back 👋",
                style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              "User Name",
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

  // 🔹 AI Insight (Clickable)
  Widget _buildAiInsight(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/roadmap');
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
          children: const [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "AI suggests improving your Flutter & UI skills 🔥",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
          ],
        ),
      ),
    );
  }

  // 🔹 Stats (مثل الشركة)
  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        _card("Skills", "12", Icons.psychology, Colors.blue),
        const SizedBox(width: 16),
        _card("Completed", "5", Icons.check_circle, Colors.green),
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
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // 🔹 Skills Progress (جديد 🔥)
  Widget _buildSkillsProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Skills",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _skill("Flutter", 0.8),
        _skill("UI/UX", 0.6),
        _skill("Backend", 0.4),
      ],
    );
  }

  Widget _skill(String name, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
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
        const Text("Your Roadmap",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.map, color: Colors.blue),
              const SizedBox(width: 12),
              const Expanded(child: Text("Continue your roadmap")),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  Navigator.pushNamed(context, '/roadmap');
                },
              )
            ],
          ),
        )
      ],
    );
  }

  // 🔹 Recent Activity (جديد 🔥)
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Activity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _activity("Uploaded CV", Icons.upload),
        _activity("Completed Flutter Basics", Icons.check),
      ],
    );
  }

  Widget _activity(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  // 🔹 Actions
  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _actionButton("Upload CV", Icons.upload, () {
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
      ),
    );
  }
}