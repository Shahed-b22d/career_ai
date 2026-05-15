import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../services/ai_api_service.dart';
import 'quiz_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RoadmapScreen extends StatefulWidget {
  final String targetJob;
  final List<String> missingSkills;

  const RoadmapScreen({super.key, required this.targetJob, required this.missingSkills});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  // Roadmap Data with Completion State
  List<Map<String, dynamic>> roadmapSteps = [];
  bool isLoading = true;
  String fullRoadmapText = "";
  
  int _loadingTextIndex = 0;
  final List<String> _loadingMessages = [
    "Analyzing your career goals...",
    "Finding the best courses...",
    "Designing your skill path...",
    "Mapping out your future steps...",
    "Consulting AI Mentors...",
  ];

  @override
  void initState() {
    super.initState();
    _startLoadingMessages();
    _fetchRoadmap();
  }

  void _startLoadingMessages() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && isLoading) {
        setState(() {
          _loadingTextIndex = (_loadingTextIndex + 1) % _loadingMessages.length;
        });
        _startLoadingMessages();
      }
    });
  }

  Future<void> _fetchRoadmap() async {
    try {
      Map<String, dynamic>? response;
      if (widget.missingSkills.isEmpty) {
        response = await AiApiService.getActiveRoadmap();
      } else {
        response = await AiApiService.generateRoadmap(widget.targetJob, widget.missingSkills);
      }

      if (response != null && response['data'] != null) {
        final data = response['data'];
        fullRoadmapText = data['roadmap'] ?? "";
        final completedSkills = data['completed_skills'] as List<dynamic>? ?? [];
        
        final skillsCourses = data['skills_courses'] as List<dynamic>?;
        if (skillsCourses != null) {
          roadmapSteps = skillsCourses.map((sc) {
            final skill = sc['skill'] ?? "Unknown Skill";
            return {
              "title": skill,
              "description": "Master this skill by exploring the recommended free courses.",
              "courses": sc['courses'] ?? [],
              "duration": "Self-paced",
              "isCompleted": completedSkills.contains(skill),
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("Roadmap Fetch Error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  double get _progressPercentage {
    if (roadmapSteps.isEmpty) return 0.0;
    int completedCount = roadmapSteps.where((step) => step["isCompleted"] == true).length;
    return completedCount / roadmapSteps.length;
  }

  void _openCourseSheet(Map<String, dynamic> step) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final List courses = step["courses"] ?? [];
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.play_lesson_rounded, color: AppTheme.primaryColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      step["title"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Recommended Free Courses",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: courses.isEmpty
                    ? const Center(child: Text("No courses found for this skill."))
                    : ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          final isYouTube = course['platform'] == 'YouTube';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue.shade200),
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isYouTube ? Icons.smart_display : Icons.school,
                                      color: isYouTube ? Colors.red : Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      course['platform'] ?? "Online Platform",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isYouTube ? Colors.red : Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  course['title'] ?? "Course Link",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      String url = course["url"] ?? "";
                                      if (url.isNotEmpty) {
                                        if (!url.startsWith("http://") && !url.startsWith("https://")) {
                                          url = "https://" + url;
                                        }
                                        final uri = Uri.parse(url);
                                        try {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Could not launch URL: $url')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.open_in_new, size: 18),
                                    label: const Text("Open Course"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Close",
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _takeQuiz(int index) async {
    final skillName = roadmapSteps[index]["title"];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(skillName: skillName)),
    );

    if (result == true) {
      // حفظ التقدم في السيرفر
      await AiApiService.updateRoadmapProgress(skillName);
      
      setState(() {
        roadmapSteps[index]["isCompleted"] = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Congratulations! You've mastered $skillName."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Learning Roadmap"),
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
      body: isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _loadingMessages[_loadingTextIndex],
                      key: ValueKey<int>(_loadingTextIndex),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ) 
          : Column(
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _progressPercentage,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                        strokeCap: StrokeCap.round,
                      ),
                      Text(
                        "${(_progressPercentage * 100).toInt()}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Progress",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Complete quizzes to advance your career.",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Roadmap Timeline
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: roadmapSteps.length,
              itemBuilder: (context, index) {
                final step = roadmapSteps[index];
                return _buildRoadmapStep(
                  stepNumber: index + 1,
                  step: step,
                  index: index,
                  isLast: index == roadmapSteps.length - 1,
                );
              },
            ),
          ),
          
          // Back to Dashboard Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/userDashboard', (route) => false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                child: const Text(
                  "Back to Dashboard",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapStep({
    required int stepNumber,
    required Map<String, dynamic> step,
    required int index,
    required bool isLast,
  }) {
    final bool isCompleted = step["isCompleted"];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line and Circle
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isCompleted ? const LinearGradient(colors: [Colors.green, Color(0xFF43A047)]) : AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isCompleted ? Colors.green : AppTheme.primaryColor).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          "$stepNumber",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    color: isCompleted ? Colors.green.withOpacity(0.5) : AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isCompleted ? Border.all(color: Colors.green.shade200, width: 2) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step["title"],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Completed",
                              style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step["description"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (!isCompleted) ...[
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppTheme.secondaryColor),
                          const SizedBox(width: 6),
                          Text(
                            step["duration"],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _openCourseSheet(step),
                              icon: const Icon(Icons.menu_book_rounded, size: 16),
                              label: const Text("Course"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: const BorderSide(color: AppTheme.primaryColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _takeQuiz(index),
                              icon: const Icon(Icons.quiz_rounded, size: 16),
                              label: const Text("Take Quiz"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
