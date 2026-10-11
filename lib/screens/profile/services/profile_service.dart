import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/links.dart';

class ProfileService {
  ProfileService._();

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/users - Fetch user profile
  static Future<Map<String, dynamic>> getProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(userProfileUrl),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return (data['user'] as Map<String, dynamic>?) ?? {};
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch profile');
    }
  }

  /// PUT /api/users - Update user profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updateData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(userProfileUrl),
      headers: headers,
      body: jsonEncode(updateData),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return (data['user'] as Map<String, dynamic>?) ?? {};
    } else {
      throw Exception(data['message'] ?? 'Failed to update profile');
    }
  }

  /// DELETE /api/users - Delete user account
  static Future<void> deleteProfile() async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse(userProfileUrl),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['status'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete profile');
    }
  }
}
