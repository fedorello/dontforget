import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.profileId,
    required super.text,
    super.notes,
    super.repeatRule,
    super.parentId,
    super.dueAt,
    super.doneAt,
    required super.isDone,
    required super.priority,
    required super.tags,
    required super.createdAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    List<String> _strings(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return TodoModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      text: json['text'] as String,
      notes: json['notes'] as String?,
      repeatRule: json['repeat_rule'] as String?,
      parentId: json['parent_id'] as String?,
      dueAt: json['due_at'] != null
          ? DateTime.parse(json['due_at'] as String)
          : null,
      doneAt: json['done_at'] != null
          ? DateTime.parse(json['done_at'] as String)
          : null,
      isDone: json['is_done'] as bool? ?? false,
      priority: json['priority'] as int? ?? 0,
      tags: _strings(json['tags']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'text': text,
        if (notes != null) 'notes': notes,
        if (dueAt != null) 'due_at': dueAt!.toIso8601String(),
        'is_done': isDone,
        'priority': priority,
        'tags': tags,
      };
}
