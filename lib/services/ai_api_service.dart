import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage_service.dart';

class AiApiService {
  // Base URL for Real Device pointing to Localhost via ADB Reverse
  static const String baseUrl = 'http://localhost:8000/api/ai';
  static const String authUrl = 'http://localhost:8000/api/auth';

  /// دالة مساعدة لتنظيف الردود القادمة من السيرفر من أي تحذيرات (PHP Warnings)
  static dynamic _cleanAndDecode(String body) {
    body = body.trim();
    if (body.isEmpty) return {};

    // إذا كان الرد لا يبدأ بقوس JSON، نبحث عن أول قوس ونتجاهل ما قبله
    if (!body.startsWith('{') && !body.startsWith('[')) {
      int startObject = body.indexOf('{');
      int startArray = body.indexOf('[');
      
      int startIndex = -1;
      if (startObject != -1 && startArray != -1) {
        startIndex = (startObject < startArray) ? startObject : startArray;
      } else if (startObject != -1) {
        startIndex = startObject;
      } else if (startArray != -1) {
        startIndex = startArray;
      }

      if (startIndex != -1) {
        body = body.substring(startIndex);
      }
    }

    try {
      return jsonDecode(body);
    } catch (e) {
      print("CRITICAL ERROR: Failed to decode JSON. Body was: $body");
      throw Exception("Invalid server response format");
    }
  }

  // Helper function to get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 1. Auth: Register
  static Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? businessType,
  }) async {
    try {
      print("DEBUG: Calling Register URL: ${Uri.parse('$authUrl/register')}");
      
      final response = await http.post(
        Uri.parse('$authUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // مطلوب للباك-إند (Laravel confirmed rule)
          'role': role,
          'phone': phone,
          'business_type': businessType,
        }),
      );

      print("DEBUG: Register Response Status: ${response.statusCode}");
      print("DEBUG: Register Response Body: ${response.body}");

      if (response.statusCode == 201) {
        final data = _cleanAndDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        // Save user profile locally
        if (data['user'] != null) {
          await LocalStorageService.saveUserProfile(
            name: data['user']['name'] ?? name,
            email: data['user']['email'] ?? email,
            role: data['user']['role'] ?? role,
            businessType: data['user']['business_type'] ?? businessType,
            phone: data['user']['phone'] ?? phone,
          );
        } else {
          await LocalStorageService.saveUserProfile(
            name: name,
            email: email,
            role: role,
            businessType: businessType,
            phone: phone,
          );
        }

        return data;
      } else {
        String errorMsg = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('message')) {
            errorMsg = decoded['message'];
          }
        } catch (_) {}
        throw Exception("Server Error (${response.statusCode}): $errorMsg");
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  // 2. Auth: Login
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print("DEBUG: Calling Login URL: ${Uri.parse('$authUrl/login')}");
      print("DEBUG: Request Body: ${jsonEncode({'email': email, 'password': password, 'role': role})}");

      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      print("DEBUG: Login Response Status: ${response.statusCode}");
      print("DEBUG: Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = _cleanAndDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        // Save user profile locally
        if (data['user'] != null) {
          await LocalStorageService.saveUserProfile(
            name: data['user']['name'],
            email: data['user']['email'],
            role: data['user']['role'],
            businessType: data['user']['business_type'],
            phone: data['user']['phone'],
          );
        }

        return data;
      } else {
        String errorMsg = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('message')) {
            errorMsg = decoded['message'];
          }
        } catch (_) {}
        throw Exception("Server Error (${response.statusCode}): $errorMsg");
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  // 3. Auth: Logout
  static Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$authUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await LocalStorageService.clearData();
        return true;
      } else {
        print("Error in logout: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception in logout: $e");
      return false;
    }
  }

  /// AI 1. Gap Analysis
  static Future<Map<String, dynamic>?> analyzeGap(String targetJob, String manualText, {File? cvFile}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/cv/gap-analysis'));
      request.headers['Accept'] = 'application/json';
      
      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['target_job'] = targetJob;
      if (manualText.isNotEmpty) {
        request.fields['manual_text'] = manualText;
      }

      if (cvFile != null) {
        request.files.add(await http.MultipartFile.fromPath('cv_file', cvFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return _cleanAndDecode(response.body);
      } else {
        print("Error in analyzeGap: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in analyzeGap: $e");
      return null;
    }
  }

  /// 2. Generate Roadmap
  static Future<Map<String, dynamic>?> generateRoadmap(String targetJob, List<String> missingSkills) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/career/roadmap'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'target_job': targetJob,
          'missing_skills': missingSkills,
        }),
      );

      if (response.statusCode == 200) {
        return _cleanAndDecode(response.body);
      } else {
        print("Error in generateRoadmap: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in generateRoadmap: $e");
      return null;
    }
  }

  /// 2b. Fetch Saved Roadmap
  static Future<Map<String, dynamic>?> getActiveRoadmap() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/career/my-roadmap'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return _cleanAndDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Exception in getActiveRoadmap: $e");
      return null;
    }
  }

  /// 2c. Update Progress
  static Future<bool> updateRoadmapProgress(String skill) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/career/update-progress'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'skill': skill}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Exception in updateProgress: $e");
      return false;
    }
  }

  /// 3. Generate Quiz
  static Future<Map<String, dynamic>?> generateQuiz(List<String> skillsToTest) async {
    try {
      final token = await getToken();
      final url = '$baseUrl/career/quiz';
      print("DEBUG: Fetching Quiz from $url");
      print("DEBUG: Token: ${token?.substring(0, 10)}...");
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', 
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'skills_to_test': skillsToTest,
        }),
      );

      print("DEBUG: Quiz Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        return _cleanAndDecode(response.body);
      } else {
        print("Error in generateQuiz: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in generateQuiz: $e");
      return null;
    }
  }

  /// 4. Generate ATS CV
  static Future<String?> generateAtsCv(String userDataText, List<String> newSkills) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/cv/generate'),
        headers: {
          'Content-Type': 'application/json', 
          'Accept': 'application/pdf',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_data_text': userDataText,
          'new_skills': newSkills,
        }),
      );

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/Professional_ATS_CV.pdf');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        print("Error in generateAtsCv: ${response.statusCode} - ${response.body}");
        try {
           final errData = jsonDecode(response.body);
           return "Error: ${errData['error'] ?? response.statusCode}";
        } catch (_) {
           return "Error: Server returned ${response.statusCode}";
        }
      }
    } catch (e) {
      print("Exception in generateAtsCv: $e");
      return "Error: $e";
    }
  }
}
