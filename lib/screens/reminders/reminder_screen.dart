import 'package:flutter/material.dart';

import 'components/add_reminder_screen.dart';
import 'components/date_helpers.dart';
import 'components/empty_reminders.dart';
import 'components/month_calendar.dart';
import 'components/reminder.dart';
import 'components/reminder_header.dart';
import 'components/reminder_tile.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final List<Reminder> _reminders = [];
  DateTime _selectedDate = DateTime.now();
  bool _calendarOpen = false;

  List<Reminder> get _selectedDayReminders => _reminders
      .where((r) => isSameDay(r.dateTime, _selectedDate))
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  bool _hasReminderOn(DateTime day) =>
      _reminders.any((r) => isSameDay(r.dateTime, day));

  Future<void> _openAddScreen() async {
    final result = await Navigator.push<Reminder>(
      context,
      MaterialPageRoute(
        builder: (_) => AddReminderScreen(
          initialDate: _selectedDate,
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _reminders.add(result);
        _selectedDate = result.dateTime;
      });
    }
  }

  void _toggleDone(Reminder r) {
    setState(() {
      final i = _reminders.indexWhere((e) => e.id == r.id);

      if (i != -1) {
        _reminders[i] = r.copyWith(isDone: !r.isDone);
      }
    });
  }

  void _delete(Reminder r) {
    setState(() {
      _reminders.removeWhere((e) => e.id == r.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _selectedDayReminders;

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
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,

      body: CustomScrollView(
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

          // Selected day's reminders.
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyReminders(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 17,
                right: 17,
                bottom: 110,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final reminder = items[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReminderTile(
                        reminder: reminder,
                        onToggleDone: () =>
                            _toggleDone(reminder),
                        onDelete: () => _delete(reminder),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}