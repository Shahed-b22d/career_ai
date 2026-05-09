import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingOverlay extends StatefulWidget {
  final List<String> loadingTexts;

  const LoadingOverlay({super.key, required this.loadingTexts});

  static void show(BuildContext context, {List<String>? texts}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingOverlay(
        loadingTexts: texts ?? ["Please wait..."],
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.loadingTexts.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.loadingTexts.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom smooth loading indicator
              SizedBox(
                width: 60,
                height: 60,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      strokeWidth: 6,
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Animated Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  widget.loadingTexts[_currentIndex],
                  key: ValueKey<int>(_currentIndex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This might take a few seconds",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
