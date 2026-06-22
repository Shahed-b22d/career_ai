import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/local_storage_service.dart';
import '../services/ai_api_service.dart';
import 'roadmap_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'complaint_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  double matchScore = 0.0;
  List<String> acquiredSkills = [];
  List<String> missingSkills = [];
  String userName = "Career Trainee";
  String userDataText = "";
  bool isLoading = true;
  String? avatarUrl;

  Map<String, dynamic>? activeRoadmap;
  double roadmapProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      var data = await LocalStorageService.getAnalysisData();
      final profile = await LocalStorageService.getUserProfile();
      
      // جلب المسار النشط من السيرفر
      final roadmapRes = await AiApiService.getActiveRoadmap();

      // جلب السيرة الذاتية الأخيرة من السيرفر لتحديث البيانات وتفادي أي أخطاء
      final latestCvRes = await AiApiService.getLatestCv();
      if (latestCvRes != null && latestCvRes['success'] == true && latestCvRes['data'] != null) {
        final cvData = latestCvRes['data'];
        final currentSkills = List<String>.from(cvData['current_skills'] ?? []);
        final missingSkillsList = List<String>.from(cvData['missing_skills'] ?? []);
        final originalText = cvData['original_text'] ?? "";
        
        double calculatedScore = data['matchScore'] ?? 0.0;
        if (calculatedScore == 0.0 && (currentSkills.isNotEmpty || missingSkillsList.isNotEmpty)) {
          final totalSkills = currentSkills.length + missingSkillsList.length;
          if (totalSkills > 0) {
            calculatedScore = currentSkills.length / totalSkills;
          }
        }

        await LocalStorageService.saveAnalysisData(
          matchScore: calculatedScore,
          acquiredSkills: currentSkills,
          missingSkills: missingSkillsList,
          cvText: originalText,
        );

        data = await LocalStorageService.getAnalysisData();
      }
      
      if (mounted) {
        setState(() {
          matchScore = data['matchScore'] ?? 0.0;
          acquiredSkills = List<String>.from(data['acquiredSkills'] ?? []);
          missingSkills = List<String>.from(data['missingSkills'] ?? []);
          userDataText = data['cvText'] ?? "";
          userName = profile['name'] ?? "Career Trainee";
          avatarUrl = profile['avatar'];
          
          if (roadmapRes != null && roadmapRes['success'] == true) {
            activeRoadmap = roadmapRes['data'];
            _calculateRoadmapProgress();
          } else {
            activeRoadmap = null;
          }
          
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Dashboard Data Error: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sync Error: $e"), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _calculateRoadmapProgress() {
    if (activeRoadmap == null) return;
    final total = (activeRoadmap!['missing_skills'] as List).length;
    final completed = (activeRoadmap!['completed_skills'] as List).length;
    if (total > 0) {
      roadmapProgress = completed / total;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildStats(context),
                      const SizedBox(height: 32),
                      _buildRoadmapSection(context),
                      const SizedBox(height: 32),
                      if (acquiredSkills.isNotEmpty || missingSkills.isNotEmpty)
                        _buildSkillsProgress(),
                      const SizedBox(height: 32),
                      _buildActions(context),
                    ],
                  ),
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
              userName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // 🔔 Notifications button
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor, size: 26),
              tooltip: 'Notifications',
            ),
            PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "edit",
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 10),
                  Text("Edit Profile"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: "complaints",
              child: Row(
                children: [
                  Icon(Icons.report_problem, color: Colors.orange),
                  SizedBox(width: 10),
                  Text("Complaints / شكاوي"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: "logout",
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Logout"),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == "logout") {
              await AiApiService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            } else if (value == "complaints") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComplaintScreen()),
              );
            } else if (value == "edit") {
              Navigator.pushNamed(context, '/personProfile').then((_) => _loadData());
            }
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE3F2FD),
            backgroundImage: avatarUrl != null
                ? NetworkImage("http://127.0.0.1:8000/storage/$avatarUrl")
                : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Colors.blue)
                : null,
          ),
        )
          ],
        )
      ],
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

  // 🔹 Roadmap Section (Dynamic & Persistent)
  Widget _buildRoadmapSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Career Journey", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: activeRoadmap != null 
            ? _activeRoadmapContent(context)
            : _emptyRoadmapContent(context),
        ),
      ],
    );
  }

  Widget _activeRoadmapContent(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeRoadmap!['target_job'] ?? "Career Path",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "You are on the right track!",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              "${(roadmapProgress * 100).toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: roadmapProgress,
            minHeight: 8,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoadmapScreen(
                    targetJob: activeRoadmap!['target_job'],
                    missingSkills: const [], // Fetch from server
                  ),
                ),
              ).then((_) => _loadData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Continue Learning"),
          ),
        ),
      ],
    );
  }

  Widget _emptyRoadmapContent(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.map_outlined, size: 40, color: Colors.grey),
        const SizedBox(height: 12),
        const Text(
          "No active roadmap yet",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        const Text(
          "Upload your CV to generate your personalized career path",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/uploadCV'),
          child: const Text("Get Started Now"),
        )
      ],
    );
  }

  // 🔹 Actions
  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _actionButton("Generate ATS CV", Icons.description_outlined, () => _generateAtsCv(context)),
        const SizedBox(height: 12),
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

  Future<void> _generateAtsCv(BuildContext context) async {
    // No need to check userDataText anymore - backend fetches it automatically
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Updated: Now uses the new API that fetches data automatically from backend
    final result = await AiApiService.generateAtsCv(includeNewSkills: true);

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result != null && !result.startsWith("Error:")) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text("Success!", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Your ATS-friendly CV has been generated successfully. What would you like to do?"),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                OpenFilex.open(result);
              },
              icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
              label: const Text("Open CV", style: TextStyle(color: AppTheme.primaryColor)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                Share.shareXFiles([XFile(result)], text: "Here is my new ATS CV generated by CareerAI!");
              },
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text("Share / Save", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${result ?? "Unknown error"}')),
      );
    }
  }
}