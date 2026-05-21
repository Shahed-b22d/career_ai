import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../services/ai_api_service.dart';
import '../services/local_storage_service.dart';

class QuizScreen extends StatefulWidget {
  final String skillName;

  const QuizScreen({super.key, required this.skillName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool isCompleted = false;
  bool isLoading = true;
  int score = 0;
  int? quizId; // Store quiz ID for submission

  List<Map<String, dynamic>> questions = [];
  List<String> userAnswers = []; // Store user's answers
  int _loadingTextIndex = 0;
  final List<String> _loadingMessages = [
    "Preparing your assessment...",
    "Generating challenge questions...",
    "Reviewing core concepts...",
    "Setting up the test environment...",
    "Get ready, starting now...",
  ];

  @override
  void initState() {
    super.initState();
    _startLoadingMessages();
    _fetchQuiz();
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

  Future<void> _fetchQuiz() async {
    print("DEBUG: QuizScreen - Starting fetch for ${widget.skillName}");
    try {
      final response = await AiApiService.generateQuiz([widget.skillName]);
      if (response != null && response['data'] != null && response['data']['quiz'] != null) {
        // Store quiz_id for later submission
        quizId = response['quiz_id'];
        
        final quizData = response['data']['quiz'] as List<dynamic>;
        if (quizData.isEmpty) {
             _showError("AI returned an empty quiz. Please try again.");
        } else {
          questions = quizData.map((q) => {
            "question": q['question'] ?? "",
            "options": q['options'] ?? [],
            "answer": q['correct_answer'] ?? ""
          }).toList();
          
          // Initialize userAnswers list
          userAnswers = List.filled(questions.length, '');
        }
      } else {
        String errorMsg = response?['error'] ?? "Failed to generate quiz questions.";
        _showError(errorMsg);
      }
    } catch (e) {
      debugPrint("Quiz Fetch Error: $e");
      _showError("Connection Error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _nextQuestion() {
    if (selectedOption == null) return;

    // Store user's answer
    userAnswers[currentQuestionIndex] = selectedOption!;

    // Calculate score locally (for immediate feedback)
    final question = questions[currentQuestionIndex];
    if (selectedOption == question["answer"]) {
      score++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
      });
    } else {
      // Quiz completed - submit to backend
      _submitQuizToBackend();
    }
  }

  Future<void> _submitQuizToBackend() async {
    if (quizId == null) {
      // Fallback to local scoring if no quiz_id
      setState(() {
        isCompleted = true;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await AiApiService.submitQuiz(
        quizId: quizId!,
        answers: userAnswers,
      );

      if (response != null && response['success'] == true) {
        // Use backend score (more accurate)
        score = (response['correct_answers'] as int?) ?? score;
        
        // If passed (70%+), the backend automatically adds skills to completed_skills
        final passed = response['passed'] as bool? ?? false;
        
        if (passed) {
          // Skill acquired - backend already updated completed_skills
          await LocalStorageService.acquireSkill(widget.skillName);
        }
      }
    } catch (e) {
      debugPrint("Quiz Submit Error: $e");
      // Continue with local score if submission fails
    }

    setState(() {
      isLoading = false;
      isCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
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
              const SizedBox(height: 16),
              Text(
                "Skill: ${widget.skillName}",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: Text("${widget.skillName} Assessment"), flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)), foregroundColor: Colors.white),
        body: const Center(child: Text("No questions available for this skill.")),
      );
    }

    if (isCompleted) {
      return _buildResultScreen();
    }

    final question = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("${widget.skillName} Assessment"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "${currentQuestionIndex + 1} / ${questions.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Question
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                question["question"],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Options
            Expanded(
              child: ListView.separated(
                itemCount: question["options"].length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = question["options"][index];
                  final isSelected = selectedOption == option;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = option;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action Button
            CustomButton(
              text: currentQuestionIndex == questions.length - 1 ? "Finish" : "Next",
              onPressed: selectedOption == null ? () {} : _nextQuestion,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    int requiredToPass = (questions.length * 0.7).ceil(); // 70% passing rate (matching backend)
    bool passed = score >= requiredToPass;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: passed ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  passed ? Icons.emoji_events_rounded : Icons.cancel_rounded, 
                  size: 80, 
                  color: passed ? Colors.green.shade600 : Colors.red.shade600
                ),
              ),
              const SizedBox(height: 24),
              Text(
                passed ? "Skill Verified!" : "Assessment Failed",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                passed 
                  ? "Great job! You scored $score out of ${questions.length} and demonstrated solid knowledge in ${widget.skillName}.\n\nThis skill has been added to your profile and will appear in your ATS CV!"
                  : "You scored $score out of ${questions.length}. You need at least 70% to pass. Please review the course materials and try again.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor, height: 1.5),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: passed ? "Continue Roadmap" : "Back to Roadmap",
                onPressed: () {
                  if (mounted) Navigator.pop(context, passed); // Return success or fail
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Navigator.pop(context);
  }
}
