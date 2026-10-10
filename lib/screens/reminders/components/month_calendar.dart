import 'package:flutter/material.dart';
import 'calendar_day_cell.dart';
import 'date_helpers.dart';

/// Simple month grid (Sunday-first) with month navigation.
class MonthCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool Function(DateTime day) hasReminderOn;

  const MonthCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.hasReminderOn,
  });

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  void _changeMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final leading = DateTime(_month.year, _month.month, 1).weekday % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final rows = ((leading + daysInMonth) / 7).ceil();
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => _changeMonth(-1),
              ),
              Expanded(
                child: Text(
                  '${kMonths[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          Row(
            children: [
              for (final l in kWeekdayLetters)
                Expanded(
                  child: Center(
                    child: Text(
                      l,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (int r = 0; r < rows; r++)
            Row(
              children: [
                for (int c = 0; c < 7; c++)
                  Expanded(child: _buildCell(r * 7 + c - leading + 1, daysInMonth, today)),
              ],
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCell(int day, int daysInMonth, DateTime today) {
    if (day < 1 || day > daysInMonth) return const SizedBox(height: 44);
    final date = DateTime(_month.year, _month.month, day);
    return CalendarDayCell(
      day: day,
      isSelected: isSameDay(date, widget.selectedDate),
      isToday: isSameDay(date, today),
      hasReminder: widget.hasReminderOn(date),
      onTap: () => widget.onDateSelected(date),
    );
  }
}
