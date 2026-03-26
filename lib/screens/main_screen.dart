import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'person_profile.dart';
import 'upload_cv_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const UploadScreen(),
    const PersonProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // 🔥 انتقال ناعم بين الصفحات
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: pages[currentIndex],
      ),

      // 🔥 البار الاحترافي
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.cloud_upload_rounded, 1),
            navItem(Icons.home_rounded, 0),
            navItem(Icons.person_rounded, 2),
          ],
        ),
      ),
    );
  }

  // 🔥 عنصر مع انيميشن فخم
  Widget navItem(IconData icon, int index) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.2 : 1,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
