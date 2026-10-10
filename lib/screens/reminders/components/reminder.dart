class Reminder {
  final String id;
  final String title;
  final String note;
  final DateTime dateTime;
  final bool isDone;

  const Reminder({
    required this.id,
    required this.title,
    this.note = '',
    required this.dateTime,
    this.isDone = false,
  });

  Reminder copyWith({bool? isDone}) => Reminder(
        id: id,
        title: title,
        note: note,
        dateTime: dateTime,
        isDone: isDone ?? this.isDone,
      );
}
