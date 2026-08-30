class Task {
  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task copyWith({
    String? title,
    bool? isCompleted,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final title = json['title'];
    final isCompleted = json['isCompleted'];
    final createdAt = json['createdAt'];
    final updatedAt = json['updatedAt'];

    if (id is! String ||
        id.trim().isEmpty ||
        title is! String ||
        title.trim().isEmpty ||
        isCompleted is! bool ||
        createdAt is! String ||
        updatedAt is! String) {
      throw const FormatException('Malformed task data.');
    }

    final created = DateTime.tryParse(createdAt);
    final updated = DateTime.tryParse(updatedAt);
    if (created == null || updated == null) {
      throw const FormatException('Malformed task dates.');
    }

    return Task(
      id: id,
      title: title.trim(),
      isCompleted: isCompleted,
      createdAt: created,
      updatedAt: updated,
    );
  }
}
