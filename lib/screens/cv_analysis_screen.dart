import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../services/ai_api_service.dart';
import '../services/local_storage_service.dart';
import 'roadmap_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class CvAnalysisScreen extends StatefulWidget {
  final Map<String, dynamic>? analysisData;
  final String targetJob;
  final String userDataText;

  const CvAnalysisScreen({super.key, this.analysisData, this.targetJob = "", this.userDataText = ""});

  @override
  State<CvAnalysisScreen> createState() => _CvAnalysisScreenState();
}

class _CvAnalysisScreenState extends State<CvAnalysisScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  List<String> acquiredSkills = [];
  List<String> missingSkills = [];
  double matchScore = 0.0;

  @override
  void initState() {
    super.initState();

    if (widget.analysisData != null && widget.analysisData!['data'] != null) {
      final data = widget.analysisData!['data'];
      
      // Parse skills safely
      if (data['current_skills'] != null) {
        acquiredSkills = List<String>.from(data['current_skills']);
      }
      if (data['missing_skills'] != null) {
        missingSkills = List<String>.from(data['missing_skills']);
      }
      
      // Parse match score securely
      if (data['match_percentage'] != null) {
        matchScore = (data['match_percentage'] as num).toDouble() / 100;
      }
      
      // 🔥 حفظ البيانات محلياً حتى تقرأها الـ Dashboard
      LocalStorageService.saveAnalysisData(
        matchScore: matchScore,
        acquiredSkills: acquiredSkills,
        missingSkills: missingSkills,
      );
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Animate to matchScore
    _progressAnimation = Tween<double>(begin: 0, end: matchScore > 0 ? matchScore : 0.75).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Data Analysis"),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Progress Indicator
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Job Match Score",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: _progressAnimation.value,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${(_progressAnimation.value * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const Text(
                                  "Match",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "You are very close to your target role!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Acquired Skills Section
            _buildSectionTitle("Acquired Skills", Icons.check_circle_rounded, Colors.green),
            const SizedBox(height: 16),
            _buildSkillsCards(acquiredSkills, Colors.green.shade50, Colors.green.shade700, Icons.verified_rounded),

            const SizedBox(height: 32),

            // Missing Skills Section
            _buildSectionTitle("Missing Skills (Needs Development)", Icons.warning_rounded, Colors.orange),
            const SizedBox(height: 16),
            _buildSkillsCards(missingSkills, Colors.orange.shade50, Colors.orange.shade800, Icons.lightbulb_outline_rounded),

            const SizedBox(height: 40),

            // Action Buttons
            CustomButton(
              text: "Generate Roadmap",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoadmapScreen(
                    targetJob: widget.targetJob,
                    missingSkills: missingSkills,
                  )),
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: "Generate ATS CV",
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
                
                final result = await AiApiService.generateAtsCv(widget.userDataText, [...acquiredSkills, ...missingSkills]);
                
                if (mounted) Navigator.pop(context);
                
                if (result != null && !result.startsWith("Error:")) {
                  // Show Success Dialog with Open and Share options
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
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
                            Navigator.pop(context); // Close dialog
                            OpenFilex.open(result); // Open PDF
                          },
                          icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
                          label: const Text("Open CV", style: TextStyle(color: AppTheme.primaryColor)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
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
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: ${result ?? "Unknown error"}')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/userDashboard', (route) => false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsCards(List<String> skills, Color bgColor, Color textColor, IconData icon) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: skills.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bgColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  skills[index],
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
