import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../services/in_app_notification_service.dart';

class NotificationBottomSheet extends StatefulWidget {
  final ValueChanged<String?>? onOpenReminder;

  const NotificationBottomSheet({
    super.key,
    this.onOpenReminder,
  });

  static Future<void> show(
    BuildContext context, {
    ValueChanged<String?>? onOpenReminder,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationBottomSheet(
        onOpenReminder: onOpenReminder,
      ),
    );
  }

  @override
  State<NotificationBottomSheet> createState() =>
      _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<NotificationBottomSheet> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (mounted) setState(() => _isLoading = true);
    await InAppNotificationService.fetchNotifications();
    if (mounted) setState(() => _isLoading = false);
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  String? _formatOffset(int? offset) {
    if (offset == null) return null;
    if (offset >= 60) {
      final h = offset ~/ 60;
      return '$h hr before';
    }
    return '$offset min before';
  }

  @override
  Widget build(BuildContext context) {
    final notifications = InAppNotificationService.notifications;
    final unreadCount = InAppNotificationService.unreadCountNotifier.value;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF10162A).withOpacity(0.97),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header with Title, Count & Action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: Color(0xFF818CF8),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text(
                                  'Notifications',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4D4F),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount new',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (notifications.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (unreadCount > 0)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      await InAppNotificationService.markAllAsRead();
                                      setState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.done_all_rounded,
                                            size: 15,
                                            color: Color(0xFF818CF8),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Mark read',
                                            style: TextStyle(
                                              color: Color(0xFF818CF8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              IconButton(
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.clear_all_rounded,
                                  color: Colors.white60,
                                  size: 20,
                                ),
                                tooltip: 'Clear all',
                                onPressed: () async {
                                  await InAppNotificationService.clearAll();
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Divider(
                    color: Colors.white.withOpacity(0.08),
                    height: 1,
                  ),

                  // Notifications List or Empty State
                  Expanded(
                    child: _isLoading && notifications.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF818CF8),
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFF818CF8),
                            backgroundColor: const Color(0xFF1B2031),
                            onRefresh: _loadNotifications,
                            child: notifications.isEmpty
                                ? _buildEmptyState()
                                : ListView.separated(
                                    controller: scrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    itemCount: notifications.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final item = notifications[index];
                                      return _buildDismissibleCard(item);
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 48,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No notifications yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "You're all caught up with your reminders and alerts.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDismissibleCard(InAppNotification item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.4),
          ),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFF87171),
          size: 24,
        ),
      ),
      onDismissed: (_) {
        InAppNotificationService.deleteNotification(item.id);
      },
      child: _buildNotificationCard(item),
    );
  }

  Widget _buildNotificationCard(InAppNotification item) {
    final offsetText = _formatOffset(item.offsetMinutes);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await InAppNotificationService.markAsRead(item.id);
          setState(() {});
          if (mounted) {
            Navigator.pop(context);
            widget.onOpenReminder?.call(item.reminderId);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead
                ? Colors.white.withOpacity(0.035)
                : const Color(0xFF6366F1).withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFF818CF8).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.isRead
                      ? const Color(0xFF1B243B)
                      : const Color(0xFF4F46E5).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.type == 'reminder'
                      ? Icons.alarm_rounded
                      : Icons.campaign_rounded,
                  color: item.isRead
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF818CF8),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Title, Body, Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (offsetText != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF818CF8).withOpacity(0.16),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              offsetText,
                              style: const TextStyle(
                                color: Color(0xFFA5B4FC),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (!item.isRead) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF818CF8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.68),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _formatTime(item.timestamp),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                        ),
                        if (item.reminderDate != null &&
                            item.reminderTime != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '•  ${item.reminderDate} ${item.reminderTime}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
