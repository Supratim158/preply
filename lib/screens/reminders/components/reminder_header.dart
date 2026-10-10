import 'package:flutter/material.dart';

import 'date_helpers.dart';

/// Top bar showing "Today" (or the selected date) with a dropdown arrow
/// that expands / collapses the month calendar.
class ReminderHeader extends StatelessWidget {
  final DateTime selectedDate;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ReminderHeader({
    super.key,
    required this.selectedDate,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(selectedDate, DateTime.now());

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Today' : kWeekdays[selectedDate.weekday - 1],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${selectedDate.day} ${kMonths[selectedDate.month - 1]} ${selectedDate.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
