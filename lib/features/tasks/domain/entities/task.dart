class Task {
  final int? id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  const Task({
    this.id,
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });

  Task copyWith({
    int? id,
    String? title,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
