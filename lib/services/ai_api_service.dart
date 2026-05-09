import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AiApiService {
  // Base URL for Android Emulator pointing to Localhost
  static const String baseUrl = 'http://10.0.2.2:8000/api/ai';

  /// دالة مساعدة لتنظيف الردود القادمة من السيرفر من أي تحذيرات (PHP Warnings)
  static dynamic _cleanAndDecode(String body) {
    body = body.trim();
    // إذا كان الرد لا يبدأ بقوس JSON، نبحث عن أول قوس ونتجاهل ما قبله
    if (!body.startsWith('{') && !body.startsWith('[')) {
      int startObject = body.indexOf('{');
      int startArray = body.indexOf('[');
      
      int startIndex = -1;
      if (startObject != -1 && startArray != -1) {
        startIndex = startObject < startArray ? startObject : startArray;
      } else if (startObject != -1) {
        startIndex = startObject;
      } else {
        startIndex = startArray;
      }
      
      if (startIndex != -1) {
        body = body.substring(startIndex);
      }
    }
    return jsonDecode(body);
  }

  /// 1. Gap Analysis
  static Future<Map<String, dynamic>?> analyzeGap(String targetJob, String manualText, {File? cvFile}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/cv/gap-analysis'));
      request.headers['Accept'] = 'application/json';
      
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
      final response = await http.post(
        Uri.parse('$baseUrl/career/roadmap'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
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

  /// 3. Generate Quiz
  static Future<Map<String, dynamic>?> generateQuiz(List<String> skillsToTest) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/career/quiz'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'skills_to_test': skillsToTest,
        }),
      );

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
      final response = await http.post(
        Uri.parse('$baseUrl/cv/generate'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/pdf'},
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
