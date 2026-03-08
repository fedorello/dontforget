class Todo {
  final String id;
  final String profileId;
  final String text;
  final String? notes;
  final String? repeatRule;
  final String? parentId;
  final DateTime? dueAt;
  final DateTime? doneAt;
  final bool isDone;
  final int priority;
  final List<String> tags;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.profileId,
    required this.text,
    this.notes,
    this.repeatRule,
    this.parentId,
    this.dueAt,
    this.doneAt,
    required this.isDone,
    required this.priority,
    required this.tags,
    required this.createdAt,
  });

  Todo copyWith({
    bool? isDone,
    DateTime? doneAt,
    int? priority,
  }) =>
      Todo(
        id: id,
        profileId: profileId,
        text: text,
        notes: notes,
        repeatRule: repeatRule,
        parentId: parentId,
        dueAt: dueAt,
        doneAt: doneAt ?? this.doneAt,
        isDone: isDone ?? this.isDone,
        priority: priority ?? this.priority,
        tags: tags,
        createdAt: createdAt,
      );
}
