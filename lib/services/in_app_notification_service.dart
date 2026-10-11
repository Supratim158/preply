import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/links.dart';
import '../screens/reminders/components/reminder.dart';

class InAppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'reminder', 'system', 'interview'
  final String? reminderId;
  final bool isRead;
  final int? offsetMinutes;
  final String? reminderDate;
  final String? reminderTime;

  const InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = 'reminder',
    this.reminderId,
    this.isRead = false,
    this.offsetMinutes,
    this.reminderDate,
    this.reminderTime,
  });

  InAppNotification copyWith({
    bool? isRead,
  }) {
    return InAppNotification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      reminderId: reminderId,
      isRead: isRead ?? this.isRead,
      offsetMinutes: offsetMinutes,
      reminderDate: reminderDate,
      reminderTime: reminderTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'reminderId': reminderId,
        'isRead': isRead,
        'offsetMinutes': offsetMinutes,
        'reminderDate': reminderDate,
        'reminderTime': reminderTime,
      };

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    DateTime ts = DateTime.now();
    if (json['createdAt'] != null) {
      ts = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else if (json['timestamp'] != null) {
      ts = DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now();
    } else if (json['reminderDate'] != null && json['reminderTime'] != null) {
      ts = DateTime.tryParse('${json['reminderDate']}T${json['reminderTime']}:00') ?? DateTime.now();
    }

    return InAppNotification(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      timestamp: ts,
      type: json['type']?.toString() ?? 'reminder',
      reminderId: json['reminderId']?.toString(),
      isRead: json['isRead'] == true,
      offsetMinutes: json['offsetMinutes'] is int
          ? json['offsetMinutes']
          : int.tryParse(json['offsetMinutes']?.toString() ?? ''),
      reminderDate: json['reminderDate']?.toString(),
      reminderTime: json['reminderTime']?.toString(),
    );
  }
}

class InAppNotificationService {
  InAppNotificationService._();

  static const String _storageKey = 'in_app_notifications_list';
  static final List<InAppNotification> _notifications = [];
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  static List<InAppNotification> get notifications =>
      List.unmodifiable(_notifications);

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Initialize: load cached notifications first, then sync with backend
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        _notifications.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _notifications.add(InAppNotification.fromJson(item));
          }
        }
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error loading cached in-app notifications: $e');
    }

    // Silently fetch from backend
    fetchNotifications().catchError((e) {
      debugPrint('Initial notifications fetch error: $e');
      return <InAppNotification>[];
    });
  }

  /// Fetch active notifications from backend GET /api/notification
  static Future<List<InAppNotification>> fetchNotifications() async {
    try {
      isLoadingNotifier.value = true;
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(notificationsUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['notifications'] is List) {
          final list = (data['notifications'] as List)
              .map((item) =>
                  InAppNotification.fromJson(item as Map<String, dynamic>))
              .toList();

          _notifications.clear();
          _notifications.addAll(list);
          _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          final int? backendUnread = data['unreadCount'] as int?;
          _updateUnreadCount(backendUnread);
          await _save();
          return notifications;
        }
      } else {
        debugPrint(
            'Failed to fetch notifications: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching notifications from backend: $e');
    } finally {
      isLoadingNotifier.value = false;
    }
    return notifications;
  }

  /// Mark specific notification as read via PATCH /api/notification/:id/read
  static Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      await _save();
    }

    try {
      final headers = await _getHeaders();
      await http.patch(
        Uri.parse('$notificationsUrl/$id/read'),
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error marking notification as read on backend: $e');
    }
  }

  /// Mark all as read via PATCH /api/notification/read-all
  static Future<void> markAllAsRead() async {
    bool hasUnread = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasUnread = true;
      }
    }
    if (hasUnread) {
      _updateUnreadCount(0);
      await _save();
    }

    try {
      final headers = await _getHeaders();
      await http.patch(
        Uri.parse('$notificationsUrl/read-all'),
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error marking all notifications as read on backend: $e');
    }
  }

  /// Dismiss / delete single notification via DELETE /api/notification/:id
  static Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    await _save();

    try {
      final headers = await _getHeaders();
      await http.delete(
        Uri.parse('$notificationsUrl/$id'),
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error deleting notification on backend: $e');
    }
  }

  /// Clear all notifications via DELETE /api/notification
  static Future<void> clearAll() async {
    _notifications.clear();
    _updateUnreadCount(0);
    await _save();

    try {
      final headers = await _getHeaders();
      await http.delete(
        Uri.parse(notificationsUrl),
        headers: headers,
      );
    } catch (e) {
      debugPrint('Error clearing all notifications on backend: $e');
    }
  }

  /// Add a new notification locally (e.g. from foreground FCM message)
  static Future<void> addNotification({
    required String title,
    required String body,
    String type = 'reminder',
    String? reminderId,
  }) async {
    final notif = InAppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      reminderId: reminderId,
      isRead: false,
    );

    _notifications.insert(0, notif);
    await _save();
    _updateUnreadCount();

    // Also trigger backend fetch to get the synced object with mongo id
    fetchNotifications().catchError((_) => <InAppNotification>[]);
  }

  /// Sync active reminders as notifications fallback
  static Future<void> syncWithReminders(List<Reminder> reminders) async {
    final now = DateTime.now();
    bool updated = false;

    for (final reminder in reminders) {
      if (reminder.isDone || reminder.status == 'cancelled') continue;

      final existingIndex = _notifications.indexWhere(
          (n) => n.reminderId == reminder.id || n.id == 'rem_${reminder.id}');

      if (existingIndex == -1) {
        final notif = InAppNotification(
          id: 'rem_${reminder.id}',
          title: reminder.title,
          body: reminder.note.isNotEmpty
              ? reminder.note
              : 'Scheduled for ${reminder.dateTime.hour.toString().padLeft(2, '0')}:${reminder.dateTime.minute.toString().padLeft(2, '0')}',
          timestamp: reminder.dateTime.isBefore(now) ? now : reminder.dateTime,
          type: 'reminder',
          reminderId: reminder.id,
          isRead: false,
        );
        _notifications.add(notif);
        updated = true;
      }
    }

    if (updated) {
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await _save();
      _updateUnreadCount();
    }
  }

  static void _updateUnreadCount([int? explicitCount]) {
    final count = explicitCount ?? _notifications.where((n) => !n.isRead).length;
    unreadCountNotifier.value = count;
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }
}
