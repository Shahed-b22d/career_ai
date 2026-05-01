import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';

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

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Which of the following best describes a key concept in this skill?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "answer": "Option B"
    },
    {
      "question": "What is the primary benefit of mastering this skill?",
      "options": ["Better performance", "Slower execution", "More bugs", "Higher cost"],
      "answer": "Better performance"
    },
    {
      "question": "How do you typically apply this skill in a real-world scenario?",
      "options": ["By guessing", "Through structured implementation", "Ignoring best practices", "Copy-pasting blindly"],
      "answer": "Through structured implementation"
    }
  ];

  void _nextQuestion() {
    if (selectedOption == null) return;

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
      });
    } else {
      setState(() {
        isCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
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
                separatorBuilder: (_, __) => const SizedBox(height: 16),
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
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events_rounded, size: 80, color: Colors.green.shade600),
              ),
              const SizedBox(height: 24),
              const Text(
                "Skill Verified!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                "Great job! You have demonstrated knowledge in ${widget.skillName}.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor, height: 1.5),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: "Continue Roadmap",
                onPressed: () {
                  Navigator.pop(context, true); // Return success
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
