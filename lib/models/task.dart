import '../Enum/RepeatFlag.dart';
import 'dart:convert';

class SubTask {
  String title;
  bool isCompleted;

  SubTask({required this.title, this.isCompleted = false});

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] == true || map['isCompleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'isCompleted': isCompleted ? 1 : 0};
  }
}

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  int priority; // 1: Low, 2: Medium, 3: High
  bool? reminder;
  DateTime? reminderDate;
  List<SubTask> subtasks;
  RepeatFlag repeatFlag;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = 2,
    this.reminder,
    this.reminderDate,
    this.subtasks = const [],
    this.repeatFlag = RepeatFlag.Once,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'reminder': reminder == true ? 1 : 0,
      'reminderDate': reminderDate?.toIso8601String(),
      'subtasks': jsonEncode(subtasks.map((s) => s.toMap()).toList()),
      'repeatFlag': repeatFlagToString(repeatFlag),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    List<SubTask> subtasks = [];
    if (map['subtasks'] != null) {
      try {
        final decoded = jsonDecode(map['subtasks']);
        if (decoded is List) {
          subtasks = decoded.map((e) => SubTask.fromMap(e)).toList();
        }
      } catch (_) {}
    }

    return Task(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate'].toString())
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      priority: (map['priority'] is int && [1, 2, 3].contains(map['priority']))
          ? map['priority']
          : 2,
      isCompleted: map['isCompleted'] == true || map['isCompleted'] == 1,
      reminder: map['reminder'] == true || map['reminder'] == 1,
      reminderDate: map['reminderDate'] != null
          ? DateTime.tryParse(map['reminderDate'].toString())
          : null,
      subtasks: subtasks,
      repeatFlag: map['repeatFlag'] != null
          ? repeatFlagFromString(map['repeatFlag'].toString())
          : RepeatFlag.Once,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    int? priority,
    bool? reminder,
    DateTime? reminderDate,
    List<SubTask>? subtasks,
    RepeatFlag? repeatFlag,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      reminder: reminder ?? this.reminder,
      reminderDate: reminderDate ?? this.reminderDate,
      subtasks: subtasks ?? this.subtasks,
      repeatFlag: repeatFlag ?? this.repeatFlag,
    );
  }
}

