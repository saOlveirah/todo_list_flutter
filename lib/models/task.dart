class Task {
  final String id;
  final String title;
  bool isCompleted;
  final DateTime date;

  Task({
    required this.id,
    required this.title,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> Json) {
    return Task(
      id: Json['id'] as String,
      title: Json['title'] as String,
      isCompleted: Json['isCompleted'] as bool,
      date: Json['date'] != null
          ? DateTime.parse(Json['date'] as String)
          : DateTime.now(),
    );
  }
}

bool isSamaDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatShortDay(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.day, date.month, date.year);
}
