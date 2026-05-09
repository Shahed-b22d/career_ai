import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyMatchScore = "cv_match_score";
  static const String _keyAcquiredSkills = "cv_acquired_skills";
  static const String _keyMissingSkills = "cv_missing_skills";

  // Save the full analysis from CvAnalysisScreen
  static Future<void> saveAnalysisData({
    required double matchScore,
    required List<String> acquiredSkills,
    required List<String> missingSkills,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMatchScore, matchScore);
    await prefs.setStringList(_keyAcquiredSkills, acquiredSkills);
    await prefs.setStringList(_keyMissingSkills, missingSkills);
  }

  // Load the current stats
  static Future<Map<String, dynamic>> getAnalysisData() async {
    final prefs = await SharedPreferences.getInstance();
    
    double score = prefs.getDouble(_keyMatchScore) ?? 0.0;
    List<String> acquired = prefs.getStringList(_keyAcquiredSkills) ?? [];
    List<String> missing = prefs.getStringList(_keyMissingSkills) ?? [];

    return {
      'matchScore': score,
      'acquiredSkills': acquired,
      'missingSkills': missing,
    };
  }

  // When a user passes a Quiz, move the skill to "Acquired" and boost score
  static Future<void> acquireSkill(String skill) async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String> acquired = prefs.getStringList(_keyAcquiredSkills) ?? [];
    List<String> missing = prefs.getStringList(_keyMissingSkills) ?? [];
    double score = prefs.getDouble(_keyMatchScore) ?? 0.0;

    if (!acquired.contains(skill)) {
      acquired.add(skill);
      missing.remove(skill);
      
      // Increase score dynamically up to 1.0 (100%)
      score += 0.1; // Add 10% for each skill acquired
      if (score > 1.0) score = 1.0;

      await prefs.setStringList(_keyAcquiredSkills, acquired);
      await prefs.setStringList(_keyMissingSkills, missing);
      await prefs.setDouble(_keyMatchScore, score);
    }
  }

  // Clear data (e.g. on logout or new CV upload)
  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMatchScore);
    await prefs.remove(_keyAcquiredSkills);
    await prefs.remove(_keyMissingSkills);
  }
}
