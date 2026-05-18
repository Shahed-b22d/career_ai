import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyMatchScore = "cv_match_score";
  static const String _keyAcquiredSkills = "cv_acquired_skills";
  static const String _keyMissingSkills = "cv_missing_skills";

  // Profile Keys
  static const String _keyUserName = "user_name";
  static const String _keyUserEmail = "user_email";
  static const String _keyUserRole = "user_role";
  static const String _keyBusinessType = "business_type";
  static const String _keyUserPhone = "user_phone";

  // --- Profile Methods ---

  static Future<void> saveUserProfile({
    required String name,
    required String email,
    required String role,
    String? businessType,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserRole, role);
    if (businessType != null) {
      await prefs.setString(_keyBusinessType, businessType);
    }
    if (phone != null) {
      await prefs.setString(_keyUserPhone, phone);
    }
  }

  static Future<Map<String, String?>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyUserName),
      'email': prefs.getString(_keyUserEmail),
      'role': prefs.getString(_keyUserRole),
      'businessType': prefs.getString(_keyBusinessType),
      'phone': prefs.getString(_keyUserPhone),
    };
  }

  // --- Analysis Data (User Specific Keys) ---

  static Future<String> _getSuffix() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail) ?? "guest";
  }

  // Save the full analysis from CvAnalysisScreen
  static Future<void> saveAnalysisData({
    required double matchScore,
    required List<String> acquiredSkills,
    required List<String> missingSkills,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getSuffix();

    await prefs.setDouble("${_keyMatchScore}_$suffix", matchScore);
    await prefs.setStringList("${_keyAcquiredSkills}_$suffix", acquiredSkills);
    await prefs.setStringList("${_keyMissingSkills}_$suffix", missingSkills);
  }

  // Load the current stats
  static Future<Map<String, dynamic>> getAnalysisData() async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getSuffix();

    double score = prefs.getDouble("${_keyMatchScore}_$suffix") ?? 0.0;
    List<String> acquired =
        prefs.getStringList("${_keyAcquiredSkills}_$suffix") ?? [];
    List<String> missing =
        prefs.getStringList("${_keyMissingSkills}_$suffix") ?? [];

    return {
      'matchScore': score,
      'acquiredSkills': acquired,
      'missingSkills': missing,
    };
  }

  // When a user passes a Quiz, move the skill to "Acquired" and boost score
  static Future<void> acquireSkill(String skill) async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = await _getSuffix();

    List<String> acquired =
        prefs.getStringList("${_keyAcquiredSkills}_$suffix") ?? [];
    List<String> missing =
        prefs.getStringList("${_keyMissingSkills}_$suffix") ?? [];
    double score = prefs.getDouble("${_keyMatchScore}_$suffix") ?? 0.0;

    if (!acquired.contains(skill)) {
      acquired.add(skill);
      missing.remove(skill);

      // Increase score dynamically up to 1.0 (100%)
      score += 0.1; // Add 10% for each skill acquired
      if (score > 1.0) score = 1.0;

      await prefs.setStringList("${_keyAcquiredSkills}_$suffix", acquired);
      await prefs.setStringList("${_keyMissingSkills}_$suffix", missing);
      await prefs.setDouble("${_keyMatchScore}_$suffix", score);
    }
  }

  static const String _keyAppLocale = "app_locale";

  // Save selected app locale (language)
  static Future<void> saveAppLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppLocale, locale);
  }

  static Future<String?> getAppLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppLocale);
  }

  // Clear data (e.g. on logout)
  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    // We don't necessarily want to clear ALL users' data,
    // but we should clear the CURRENT user's token and profile session
    await prefs.remove('auth_token');
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyBusinessType);
    await prefs.remove(_keyUserPhone);
  }
}
