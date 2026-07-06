import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';

class AiApiService {
  // 10.0.2.2      = localhost for Android Emulator
  // 127.0.0.1     = localhost for Physical Device with `adb reverse`
  // 10.88.132.213 = Server IP (used by both emulator and physical device on same network)

  // ✅ الـ IP الحالي للسيرفر — يعمل على الموبايل الحقيقي والمحاكي على نفس الشبكة
  static const String _host    = 'http://192.168.1.107:8000';

  // (استخدم هذا السطر إذا كنت تستخدم الموبايل مع adb reverse)
  // static const String _host    = 'http://127.0.0.1:8000';

  // (هذا السطر مخصص للمحاكي فقط بدون شبكة خارجية)
  // static const String _host    = 'http://10.0.2.2:8000';

  static const String baseUrl  = '$_host/api/ai';
  static const String authUrl  = '$_host/api/auth';

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

  // Helper: get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Helper: build Authorization headers
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── 1. Auth: Register ──────────────────────────────────────────────────────
  /// Supports file upload (commercial_register_file) for companies.
  /// Uses multipart/form-data so it works with and without a file.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String governorate,
    String? phone,
    String? businessType,
    File? commercialRegisterFile,
  }) async {
    try {
      final token = await getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$authUrl/register'),
      );

      request.headers['Accept'] = 'application/json';
      if (token != null) request.headers['Authorization'] = 'Bearer $token';

      // Text fields
      request.fields['name']        = name;
      request.fields['email']       = email;
      request.fields['password']    = password;
      request.fields['role']        = role;
      request.fields['governorate']  = governorate;
      if (phone != null && phone.isNotEmpty) {
        request.fields['phone'] = phone;
      }
      if (businessType != null && businessType.isNotEmpty) {
        request.fields['business_type'] = businessType;
      }

      // File field (company only)
      if (commercialRegisterFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'commercial_register_file',
            commercialRegisterFile.path,
          ),
        );
      }

      final streamed  = await request.send();
      final response  = await http.Response.fromStream(streamed);

      if (response.statusCode == 201) {
        final data = _cleanAndDecode(response.body) as Map<String, dynamic>;

        // شركات جديدة لا يرجع لها token — بتحتاج موافقة الأدمن أولاً
        if (data['requires_approval'] == true) {
          return data;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        if (data['user'] != null) {
          await LocalStorageService.saveUserProfile(
            name:         data['user']['name']          ?? name,
            email:        data['user']['email']         ?? email,
            role:         data['user']['role']          ?? role,
            businessType: data['user']['business_type'] ?? data['user']['company']?['business_type'] ?? businessType,
            phone:        data['user']['phone']         ?? phone,
            governorate:  data['user']['governorate']   ?? governorate,
            avatar:       data['user']['avatar_path'],
            description:  data['user']['company']?['description'],
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
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ─── 1.5. Auth: Google Login / Register ─────────────────────────────────────
  /// يُرسل Firebase ID Token إلى الباك إند للتحقق منه وإرجاع Sanctum token.
  /// يعمل لكل من تسجيل الدخول (مستخدم موجود) والتسجيل الأول (مستخدم جديد).
  static Future<Map<String, dynamic>> googleLogin({
    required String idToken,
    required String role,
    String? governorate,
    String? phone,
    String? businessType,
    File? commercialRegisterFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$authUrl/google-login'),
      );

      request.headers['Accept'] = 'application/json';

      request.fields['id_token'] = idToken;
      request.fields['role'] = role;
      if (governorate != null && governorate.isNotEmpty) {
        request.fields['governorate'] = governorate;
      }
      if (phone != null && phone.isNotEmpty) {
        request.fields['phone'] = phone;
      }
      if (businessType != null && businessType.isNotEmpty) {
        request.fields['business_type'] = businessType;
      }
      if (commercialRegisterFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'commercial_register_file',
            commercialRegisterFile.path,
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = _cleanAndDecode(response.body) as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        if (data['user'] != null) {
          final user = data['user'];
          await LocalStorageService.saveUserProfile(
            name: user['name'] ?? '',
            email: user['email'] ?? '',
            role: user['role'] ?? role,
            businessType:
                user['business_type'] ?? user['company']?['business_type'] ?? businessType,
            phone: user['phone'] ?? phone,
            governorate: user['governorate'] ?? governorate,
            avatar: user['avatar_path'],
            description: user['company']?['description'],
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
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ─── 2. Auth: Login ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      print("DEBUG: Attempting Login to $authUrl/login");
      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email':    email,
          'password': password,
          'role':     role,
        }),
      );
      print("DEBUG: Login Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = _cleanAndDecode(response.body) as Map<String, dynamic>;
        print("DEBUG: Login Success. Token saved.");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        if (data['user'] != null) {
          await LocalStorageService.saveUserProfile(
            name:         data['user']['name'],
            email:        data['user']['email'],
            role:         data['user']['role'],
            businessType: data['user']['business_type'] ?? data['user']['company']?['business_type'],
            phone:        data['user']['phone'],
            governorate:  data['user']['governorate'],
            avatar:       data['user']['avatar_path'],
            description:  data['user']['company']?['description'],
          );
        }
        return data;
      } else {
        print("DEBUG: Login Failed: ${response.body}");
        String errorMsg = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('message')) {
            errorMsg = decoded['message'];
          }
        } catch (e) {
          print("DEBUG: Error decoding error response: $e");
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      print("DEBUG: Login Exception: $e");
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ─── 2.5 Auth: Update Profile ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? governorate,
    String? businessType,
    String? description,
    File? avatarFile,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("Unauthorized");

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$authUrl/profile/update'),
      );

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      if (name != null) request.fields['name'] = name;
      if (email != null) request.fields['email'] = email;
      if (phone != null) request.fields['phone'] = phone;
      if (governorate != null) request.fields['governorate'] = governorate;
      if (businessType != null) request.fields['business_type'] = businessType;
      if (description != null) request.fields['description'] = description;

      if (avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', avatarFile.path),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = _cleanAndDecode(response.body) as Map<String, dynamic>;
        if (data['user'] != null) {
          await LocalStorageService.saveUserProfile(
            name: data['user']['name'],
            email: data['user']['email'],
            role: data['user']['role'],
            businessType: data['user']['business_type'] ?? data['user']['company']?['business_type'],
            phone: data['user']['phone'],
            governorate: data['user']['governorate'],
            avatar: data['user']['avatar_path'],
            description: data['user']['company']?['description'],
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
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
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

  // 3a. Auth: Update FCM Token
  static Future<void> updateFcmToken(String fcmToken) async {
    try {
      final headers = await getAuthHeaders();
      await http.post(
        Uri.parse('$authUrl/fcm-token'),
        headers: headers,
        body: jsonEncode({'fcm_token': fcmToken}),
      );
    } catch (e) {
      print('updateFcmToken error: $e');
    }
  }

  // 3b. Auth: Forgot Password — يرسل رابط إعادة التعيين على الإيميل
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final data = _cleanAndDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Reset link sent.'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Something went wrong.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // 3c. Auth: Reset Password — يحدّث كلمة المرور بالتوكن
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = _cleanAndDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Password reset.'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid or expired token.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// شكاوى المستخدم الحالي
  static Future<List<dynamic>> getMyComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('$_host/api/complaints/mine'),
        headers: await getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final data = _cleanAndDecode(response.body) as Map<String, dynamic>;
        return data['data'] as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      print('getMyComplaints error: $e');
      return [];
    }
  }

  // 4. Submit Complaint
  static Future<Map<String, dynamic>> submitComplaint({
    required String subject,
    required String message,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception("Unauthorized");

      final response = await http.post(
        Uri.parse('$_host/api/complaints'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'subject': subject,
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        return _cleanAndDecode(response.body);
      } else {
        String errorMsg = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('message')) {
            errorMsg = decoded['message'];
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// AI 1. Gap Analysis
  static Future<Map<String, dynamic>?> analyzeGap(String targetJob, String manualText, {File? cvFile}) async {
    try {
      print("DEBUG: Starting Gap Analysis for $targetJob");
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
      print("DEBUG: Gap Analysis Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return _cleanAndDecode(response.body);
      } else {
        print("DEBUG: Gap Analysis Error Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("DEBUG: Gap Analysis Exception: $e");
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

  /// 3b. Submit Quiz Answers (NEW)
  /// Returns the score and whether the user passed (70%+)
  static Future<Map<String, dynamic>?> submitQuiz({
    required int quizId,
    required List<String> answers,
  }) async {
    try {
      final token = await getToken();
      final url = '$baseUrl/career/quiz/submit';
      print("DEBUG: Submitting Quiz to $url");
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'quiz_id': quizId,
          'answers': answers,
        }),
      );

      print("DEBUG: Submit Quiz Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        return _cleanAndDecode(response.body);
      } else {
        print("Error in submitQuiz: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in submitQuiz: $e");
      return null;
    }
  }

  /// 4. Generate ATS CV (UPDATED - Now fetches data automatically from backend)
  /// The backend will automatically fetch:
  /// - Latest CV from user_resumes
  /// - Acquired skills from user_roadmaps.completed_skills
  /// - Merge all skills and generate professional ATS CV
  static Future<String?> generateAtsCv({bool includeNewSkills = true}) async {
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
          'include_new_skills': includeNewSkills,
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
           return "Error: ${errData['error'] ?? errData['message'] ?? response.statusCode}";
        } catch (_) {
           return "Error: Server returned ${response.statusCode}";
        }
      }
    } catch (e) {
      print("Exception in generateAtsCv: $e");
      return "Error: $e";
    }
  }

  /// Get the latest CV text and analysis from the server
  static Future<Map<String, dynamic>?> getLatestCv() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/cv/latest'),
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
      print("Exception in getLatestCv: $e");
      return null;
    }
  }

  /// Create a new job listing and get the Stripe Checkout Session URL
  static Future<Map<String, dynamic>?> createJobAndGetCheckoutUrl({
    required String title,
    required String jobType,
    required String location,
    required String salary,
    required String description,
    required String requirements,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$_host/api/jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'job_type': jobType,
          'location': location,
          'salary': salary,
          'description': description,
          'requirements': requirements,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _cleanAndDecode(response.body);
      } else {
        print("Error in createJobAndGetCheckoutUrl: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in createJobAndGetCheckoutUrl: $e");
      return null;
    }
  }

  /// Get all active paid jobs from the server
  static Future<List<dynamic>?> getActiveJobs() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$_host/api/jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final res = _cleanAndDecode(response.body);
        if (res != null && res['success'] == true) {
          return res['data'] as List<dynamic>;
        }
      }
      return null;
    } catch (e) {
      print("Exception in getActiveJobs: $e");
      return null;
    }
  }

  /// Get Company Dashboard details dynamically
  static Future<Map<String, dynamic>?> getCompanyDashboardData() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$_host/api/company/dashboard'),
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
      print("Exception in getCompanyDashboardData: $e");
      return null;
    }
  }

  /// Get ALL suggested candidates for the Suggested Profiles screen
  static Future<List<dynamic>?> getSuggestedCandidates() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$_host/api/candidates/suggested'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final res = _cleanAndDecode(response.body);
        if (res != null && res['success'] == true) {
          return res['data'] as List<dynamic>;
        }
      }
      return null;
    } catch (e) {
      print("Exception in getSuggestedCandidates: $e");
      return null;
    }
  }

  /// Shortlist a candidate — triggers real FCM notification and saves to DB
  static Future<Map<String, dynamic>> shortlistCandidate(int userId, {int? jobId}) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$_host/api/candidates/$userId/shortlist'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (jobId != null) 'job_id': jobId,
        }),
      );

      if (response.statusCode == 200) {
        return _cleanAndDecode(response.body) as Map<String, dynamic>;
      } else {
        final err = _cleanAndDecode(response.body);
        return {'success': false, 'message': err['message'] ?? 'Failed to shortlist'};
      }
    } catch (e) {
      print("Exception in shortlistCandidate: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Get a single job seeker profile for the Candidate Profile screen
  static Future<Map<String, dynamic>?> getCandidateProfile(int userId, {int? jobId}) async {
    try {
      final token = await getToken();
      final uri = jobId != null
          ? Uri.parse('$_host/api/candidates/$userId?job_id=$jobId')
          : Uri.parse('$_host/api/candidates/$userId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final res = _cleanAndDecode(response.body);
        if (res != null && res['success'] == true) {
          return Map<String, dynamic>.from(res['data'] as Map);
        }
      }
      return null;
    } catch (e) {
      print("Exception in getCandidateProfile: $e");
      return null;
    }
  }

  /// Get all AI-matched candidates for a specific job posting
  /// Returns candidates sorted by match_score descending (from job_candidate_scores table)
  static Future<Map<String, dynamic>?> getJobCandidates(int jobId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$_host/api/jobs/$jobId/candidates'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final res = _cleanAndDecode(response.body);
        if (res != null && res['success'] == true) {
          return Map<String, dynamic>.from(res as Map);
        }
      }
      return null;
    } catch (e) {
      print("Exception in getJobCandidates: $e");
      return null;
    }
  }
}
