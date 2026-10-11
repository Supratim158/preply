import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/links.dart';
import '../components/reminder.dart';

class ReminderService {
  ReminderService._();

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Create a new reminder via POST /api/reminders
  static Future<Reminder> createReminder({
    required String title,
    String? description,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');

    final body = jsonEncode({
      'title': title.trim(),
      'description': description?.trim() ?? '',
      'date': '$y-$m-$d',
      'time': '$h:$min',
    });

    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(remindersUrl),
      headers: headers,
      body: body,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      if (data['reminder'] != null) {
        return Reminder.fromJson(data['reminder'] as Map<String, dynamic>);
      }
      throw Exception('Reminder data missing in response');
    } else {
      throw Exception(data['message'] ?? 'Failed to create reminder');
    }
  }

  /// Fetch all reminders via GET /api/reminders
  static Future<List<Reminder>> getAllReminders() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(remindersUrl),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final list = (data['reminders'] as List? ?? []);
      return list
          .map((item) => Reminder.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch reminders');
    }
  }

  /// Mark reminder as done via PATCH /api/reminders/:id/done
  static Future<Reminder> markDone(String id) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$remindersUrl/$id/done'),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['reminder'] != null) {
        return Reminder.fromJson(data['reminder'] as Map<String, dynamic>);
      }
      throw Exception('Reminder data missing in response');
    } else {
      throw Exception(data['message'] ?? 'Failed to mark reminder as done');
    }
  }

  /// Delete reminder via DELETE /api/reminders/:id
  static Future<void> deleteReminder(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$remindersUrl/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to delete reminder');
    }
  }
}
