import 'package:flutter/material.dart';

class EmptyReminders extends StatelessWidget {
  const EmptyReminders({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 56, color: Colors.white24),
          SizedBox(height: 12),
          Text(
            'No reminders for this day',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
