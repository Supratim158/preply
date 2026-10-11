import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:preply/screens/home/components/action_glass_card.dart';
import 'package:preply/screens/home/components/ai_career_insight.dart';

import '../../services/in_app_notification_service.dart';
import '../reminders/components/date_helpers.dart';
import '../reminders/components/reminder.dart';
import '../reminders/services/reminder_service.dart';
import 'components/upcoming_reminders_card.dart';
import 'components/your_progress_card.dart';

class Homescreen extends StatefulWidget {
  final ValueChanged<int> onNavigateTab;

  const Homescreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    try {
      final items = await ReminderService.getAllReminders();
      // Also sync notifications with backend in parallel
      InAppNotificationService.fetchNotifications().catchError((_) => <InAppNotification>[]);

      if (!mounted) return;
      setState(() {
        _reminders = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Reminder> get _upcomingReminders {
    // Only pending, non-cancelled reminders sorted ascending by dateTime
    return _reminders
        .where((r) => !r.isDone && r.status != 'cancelled')
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  String _formatReminderTime(DateTime dt) {
    final now = DateTime.now();
    final timeStr = TimeOfDay.fromDateTime(dt).format(context);
    if (isSameDay(dt, now)) {
      return 'Today, $timeStr';
    } else if (isSameDay(dt, now.add(const Duration(days: 1)))) {
      return 'Tomorrow, $timeStr';
    } else {
      final monthShort = kMonths[dt.month - 1].substring(0, 3);
      return '$monthShort ${dt.day}, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF8CB7FF),
      backgroundColor: const Color(0xFF10131F),
      onRefresh: _fetchReminders,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 17,
                right: 17,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome heading
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Hello, Supratim',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Lottie.asset(
                          'assets/animations/waving hand.json',
                          repeat: true,
                          animate: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  const Text(
                    "Let's prepare you for your next opportunity.",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // AI Career Insight
                  const AICareerInsight(),

                  const SizedBox(height: 15),

                  // Progress cards
                  YourProgressCard(
                    resumeScore: '--',
                    onResumeTap: () {
                      widget.onNavigateTab(1);
                    },
                    interviewScore: '--',
                    onInterviewTap: () {
                      widget.onNavigateTab(2);
                    },
                    skillsProgress: '--',
                    onSkillsTap: () {
                      widget.onNavigateTab(1);
                    },
                    interviewsPracticed: 0,
                    onPracticedTap: () {
                      widget.onNavigateTab(2);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Upcoming Reminders heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 17,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Upcoming Reminders",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.onNavigateTab(3);
                        },
                        child: const Text(
                          "View All Reminders",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Dynamic Upcoming Reminders from backend
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8CB7FF),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (_upcomingReminders.isEmpty)
                    GestureDetector(
                      onTap: () {
                        widget.onNavigateTab(3);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF182441),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.event_available_rounded,
                                color: Color(0xFF8CB7FF),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No upcoming reminders',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Tap here to add a new reminder',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white38,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._upcomingReminders.take(3).map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: UpcomingReminders(
                            title: r.title,
                            description: r.note.isNotEmpty
                                ? r.note
                                : 'Scheduled for ${_formatReminderTime(r.dateTime)}',
                            reminderTime: _formatReminderTime(r.dateTime),
                            icon: Icons.event_note_rounded,
                            onTap: () {
                              widget.onNavigateTab(3);
                            },
                          ),
                        )),

                  const SizedBox(height: 15),

                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.30,
                    padding: EdgeInsets.zero,
                    children: [
                      ActionGlassCard(
                        icon: Icons.description_outlined,
                        title: 'Resume Checker',
                        onTap: () {
                          widget.onNavigateTab(1);
                        },
                      ),
                      ActionGlassCard(
                        icon: Icons.voice_chat_outlined,
                        title: 'Mock Interview',
                        onTap: () {
                          widget.onNavigateTab(2);
                        },
                      ),
                      ActionGlassCard(
                        icon: Icons.event_available_rounded,
                        title: 'Reminders',
                        onTap: () {
                          widget.onNavigateTab(3);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
