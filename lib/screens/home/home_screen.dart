import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool hasCV = false;

  late AnimationController _controller;
  late Animation<double> fade;
  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    slide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔥 EMPTY STATE
  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.8, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.upload_file,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Start Your Journey 🚀",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const Text(
            "Upload your CV to generate your\ncareer roadmap",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 25),

          // ✅ التعديل هون فقط
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/uploadCV');

              if (result == true) {
                setState(() {
                  hasCV = true;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: Colors.blue,
            ),
            child: const Text("Upload CV"),
          ),
        ],
      ),
    );
  }

  // 🔥 ROADMAP
  Widget buildRoadmap() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 0.65),
            duration: const Duration(seconds: 1),
            builder: (context, value, _) {
              return SizedBox(
                height: 170,
                width: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    Text(
                      "${(value * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          roadmapItem("Learn Flutter Basics"),
          roadmapItem("Build Real Projects"),
          roadmapItem("State Management"),
          roadmapItem("Practice Interviews"),
        ],
      ),
    );
  }

  Widget roadmapItem(String text) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 20.0, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // ❌ ما في BottomNavigationBar هون (انحذف)
      body: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 25),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Career Roadmap",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: hasCV ? buildRoadmap() : buildEmptyState(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
