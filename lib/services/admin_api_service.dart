import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminApiService {
  static const String _host = 'http://127.0.0.1:8000';
  static const String baseUrl = '$_host/api/admin';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
  }

  static dynamic _decode(String body) {
    body = body.trim();
    if (!body.startsWith('{') && !body.startsWith('[')) {
      final i = body.indexOf('{');
      if (i != -1) body = body.substring(i);
    }
    return jsonDecode(body);
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      await _saveToken(data['token']);
      return data;
    }
    throw Exception(data['message'] ?? 'Login failed');
  }

  static Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/logout'), headers: await _headers());
    } catch (_) {}
    await clearToken();
  }

  static Future<Map<String, dynamic>?> getDashboard() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard'), headers: await _headers());
    if (response.statusCode == 200) {
      return _decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<List<dynamic>> getPendingCompanies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/verifications/companies'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = _decode(response.body) as Map<String, dynamic>;
      return data['data'] as List<dynamic>? ?? [];
    }
    return [];
  }

  static Future<bool> approveCompany(int companyId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verifications/companies/$companyId/approve'),
      headers: await _headers(),
    );
    return response.statusCode == 200;
  }

  static Future<bool> rejectCompany(int companyId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verifications/companies/$companyId/reject'),
      headers: await _headers(),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getPendingPayments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/jobs'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = _decode(response.body) as Map<String, dynamic>;
      return data['data'] as List<dynamic>? ?? [];
    }
    return [];
  }

  static Future<bool> confirmPayment(int jobId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/jobs/$jobId/confirm'),
      headers: await _headers(),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> getComplaints({String status = 'all'}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/complaints?status=$status'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return _decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> resolveComplaint({
    required int complaintId,
    required String status,
    String? adminResponse,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/complaints/$complaintId'),
      headers: await _headers(),
      body: jsonEncode({
        'status': status,
        if (adminResponse != null && adminResponse.isNotEmpty)
          'admin_response': adminResponse,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getTalentActivity() async {
    final response = await http.get(
      Uri.parse('$baseUrl/talent-activity'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = _decode(response.body) as Map<String, dynamic>;
      return data['data'] as List<dynamic>? ?? [];
    }
    return [];
  }
}
