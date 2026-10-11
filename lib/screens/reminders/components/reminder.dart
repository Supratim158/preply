class Reminder {
  final String id;
  final String title;
  final String note;
  final DateTime dateTime;
  final bool isDone;
  final String status;

  const Reminder({
    required this.id,
    required this.title,
    this.note = '',
    required this.dateTime,
    this.isDone = false,
    this.status = 'pending',
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final dateStr = (json['date'] as String?) ?? '';
    final timeStr = (json['time'] as String?) ?? '00:00';
    DateTime dt;
    try {
      final dateParts = dateStr.split('-');
      final timeParts = timeStr.split(':');
      dt = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (_) {
      dt = DateTime.now();
    }

    final status = (json['status'] as String?) ?? 'pending';

    return Reminder(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      note: (json['description'] ?? json['note'] ?? '').toString(),
      dateTime: dt,
      status: status,
      isDone: status == 'done',
    );
  }

  Map<String, dynamic> toJson() {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');

    return {
      'title': title,
      'description': note,
      'date': '$y-$m-$d',
      'time': '$h:$min',
    };
  }

  Reminder copyWith({bool? isDone, String? status}) => Reminder(
        id: id,
        title: title,
        note: note,
        dateTime: dateTime,
        isDone: isDone ?? this.isDone,
        status: status ?? this.status,
      );
}
