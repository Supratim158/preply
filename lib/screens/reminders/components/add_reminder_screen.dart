import 'package:flutter/material.dart';
import 'package:preply/screens/reminders/components/reminder.dart';

import 'date_helpers.dart';
import 'date_time_field.dart';

class AddReminderScreen extends StatefulWidget {
  final DateTime initialDate;

  const AddReminderScreen({super.key, required this.initialDate});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _date;
  late TimeOfDay _time;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _time = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Please enter a title');
      return;
    }
    final reminder = Reminder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      note: _noteController.text.trim(),
      dateTime: DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute),
    );
    Navigator.pop(context, reminder);
  }

  InputDecoration _decoration(String hint, {String? error}) => InputDecoration(
        hintText: hint,
        errorText: error,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14161B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('New reminder'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(color: Color(0xFF4C8DF6), fontSize: 16)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: _decoration('Title', error: _titleError),
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _decoration('Add note (optional)'),
          ),
          const SizedBox(height: 20),
          DateTimeField(
            icon: Icons.calendar_today_outlined,
            label: formatFullDate(_date),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          DateTimeField(
            icon: Icons.access_time,
            label: _time.format(context),
            onTap: _pickTime,
          ),
        ],
      ),
    );
  }
}
