import 'user.dart';

enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  const TaskPriority(this.value, this.label);
  final String value;
  final String label;

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

enum TaskStatus {
  pending('pending', 'Pending'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const TaskStatus(this.value, this.label);
  final String value;
  final String label;

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

class Task {
  final int id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final User sender;
  final User receiver;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final bool isReminderSent;
  final String notes;
  final bool isOverdue;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.sender,
    required this.receiver,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    required this.isReminderSent,
    required this.notes,
    required this.isOverdue,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority:
          TaskPriority.fromString(json['priority'] as String? ?? 'medium'),
      status: TaskStatus.fromString(json['status'] as String? ?? 'pending'),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      receiver: User.fromJson(json['receiver'] as Map<String, dynamic>),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      isReminderSent: json['is_reminder_sent'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      isOverdue: json['is_overdue'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.value,
      'status': status.value,
      'due_date': dueDate?.toIso8601String(),
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_reminder_sent': isReminderSent,
      'notes': notes,
      'is_overdue': isOverdue,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    User? sender,
    User? receiver,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool? isReminderSent,
    String? notes,
    bool? isOverdue,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      isReminderSent: isReminderSent ?? this.isReminderSent,
      notes: notes ?? this.notes,
      isOverdue: isOverdue ?? this.isOverdue,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: ${status.label}, priority: ${priority.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Task creation/update request model
class TaskRequest {
  final String title;
  final String description;
  final String priority;
  final String? status;
  final DateTime? dueDate;
  final String? receiverUserId;
  final String? notes;

  TaskRequest({
    required this.title,
    required this.description,
    required this.priority,
    this.status,
    this.dueDate,
    this.receiverUserId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority,
    };

    if (status != null) json['status'] = status;
    if (dueDate != null) json['due_date'] = dueDate!.toIso8601String();
    if (receiverUserId != null) json['receiver_user_id'] = receiverUserId;
    if (notes != null) json['notes'] = notes;

    return json;
  }
}
