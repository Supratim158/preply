import 'package:flutter/material.dart';

import '../../utils/app_snackbar.dart';
import '../../widgets/animated_page_transition.dart';
import 'components/add_reminder_screen.dart';
import 'components/date_helpers.dart';
import 'components/month_calendar.dart';
import 'components/reminder.dart';
import 'components/reminder_header.dart';
import 'components/reminder_tile.dart';
import 'services/reminder_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final List<Reminder> _reminders = [];
  DateTime _selectedDate = DateTime.now();
  bool _calendarOpen = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    setState(() => _isLoading = true);
    try {
      final items = await ReminderService.getAllReminders();
      if (!mounted) return;
      setState(() {
        _reminders.clear();
        _reminders.addAll(items);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppSnackBar(
        context,
        'Failed to load reminders: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  List<Reminder> get _todayReminders {
    final now = DateTime.now();
    return _reminders.where((r) => isSameDay(r.dateTime, now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Reminder> get _upcomingReminders {
    final now = DateTime.now();
    return _reminders.where((r) => !isSameDay(r.dateTime, now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  bool _hasReminderOn(DateTime day) =>
      _reminders.any((r) => isSameDay(r.dateTime, day));

  Future<void> _openAddScreen() async {
    final result = await AppTransitions.push<Reminder>(
      context,
      AddReminderScreen(
        initialDate: _selectedDate,
      ),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _reminders.add(result);
        _selectedDate = result.dateTime;
      });
      _fetchReminders();
    }
  }

  Future<void> _toggleDone(Reminder r) async {
    if (r.isDone) return;

    // Optimistic update
    setState(() {
      final i = _reminders.indexWhere((e) => e.id == r.id);
      if (i != -1) {
        _reminders[i] = r.copyWith(isDone: true, status: 'done');
      }
    });

    try {
      final updated = await ReminderService.markDone(r.id);
      if (!mounted) return;
      setState(() {
        final i = _reminders.indexWhere((e) => e.id == r.id);
        if (i != -1) {
          _reminders[i] = updated;
        }
      });
    } catch (e) {
      if (!mounted) return;
      // Revert on failure
      setState(() {
        final i = _reminders.indexWhere((e) => e.id == r.id);
        if (i != -1) {
          _reminders[i] = r;
        }
      });
      showAppSnackBar(
        context,
        'Could not mark as done: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<void> _delete(Reminder r) async {
    final index = _reminders.indexWhere((e) => e.id == r.id);
    if (index == -1) return;

    setState(() {
      _reminders.removeAt(index);
    });

    try {
      await ReminderService.deleteReminder(r.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reminders.insert(index, r);
      });
      showAppSnackBar(
        context,
        'Could not delete reminder: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required int count,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySectionCard({
    required String message,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white38),
          const SizedBox(width: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayItems = _todayReminders;
    final upcomingItems = _upcomingReminders;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF4C8DF6),
          foregroundColor: Colors.white,
          onPressed: _openAddScreen,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        color: const Color(0xFF4C8DF6),
        backgroundColor: const Color(0xFF1E2230),
        onRefresh: _fetchReminders,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Reminder header and expandable calendar.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 17,
                  right: 17,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReminderHeader(
                      selectedDate: _selectedDate,
                      isExpanded: _calendarOpen,
                      onToggle: () {
                        setState(() {
                          _calendarOpen = !_calendarOpen;
                        });
                      },
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _calendarOpen
                          ? MonthCalendar(
                              selectedDate: _selectedDate,
                              hasReminderOn: _hasReminderOn,
                              onDateSelected: (date) {
                                setState(() {
                                  _selectedDate = date;
                                  _calendarOpen = false;
                                });
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                    const Divider(
                      color: Colors.white12,
                      height: 17,
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading && _reminders.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF4C8DF6),
                    ),
                  ),
                ),
              )
            else ...[
              // Section 1: Today's Reminders
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: "Today's Reminders",
                  icon: Icons.today_rounded,
                  count: todayItems.length,
                  accentColor: const Color(0xFF4C8DF6),
                ),
              ),
              if (todayItems.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmptySectionCard(
                    message: 'No reminders scheduled for today',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reminder = todayItems[index];
                      return ReminderTile(
                        reminder: reminder,
                        onToggleDone: () => _toggleDone(reminder),
                        onDelete: () => _delete(reminder),
                      );
                    },
                    childCount: todayItems.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

              // Section 2: Upcoming Reminders
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: 'Upcoming Reminders',
                  icon: Icons.upcoming_rounded,
                  count: upcomingItems.length,
                  accentColor: const Color(0xFFA78BFA),
                ),
              ),
              if (upcomingItems.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmptySectionCard(
                    message: 'No upcoming reminders',
                    icon: Icons.event_available_outlined,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reminder = upcomingItems[index];
                      return ReminderTile(
                        reminder: reminder,
                        onToggleDone: () => _toggleDone(reminder),
                        onDelete: () => _delete(reminder),
                      );
                    },
                    childCount: upcomingItems.length,
                  ),
                ),
            ],

            // Bottom spacing for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 110),
            ),
          ],
        ),
      ),
    );
  }
}
