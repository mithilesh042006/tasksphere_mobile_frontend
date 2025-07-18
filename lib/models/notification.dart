enum NotificationType {
  taskReceived('task_received', 'Task Received'),
  taskUpdated('task_updated', 'Task Updated'),
  taskCompleted('task_completed', 'Task Completed'),
  taskReminder('task_reminder', 'Task Reminder'),
  taskOverdue('task_overdue', 'Task Overdue'),
  system('system', 'System Notification');

  const NotificationType(this.value, this.label);
  final String value;
  final String label;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

class TaskSphereNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final bool isSent;
  final Map<String, dynamic> extraData;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? sentAt;

  TaskSphereNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.isSent,
    required this.extraData,
    required this.createdAt,
    this.readAt,
    this.sentAt,
  });

  factory TaskSphereNotification.fromJson(Map<String, dynamic> json) {
    return TaskSphereNotification(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      isSent: json['is_sent'] as bool? ?? false,
      extraData: json['extra_data'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String)
          : null,
      sentAt: json['sent_at'] != null 
          ? DateTime.parse(json['sent_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'is_read': isRead,
      'is_sent': isSent,
      'extra_data': extraData,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
    };
  }

  TaskSphereNotification copyWith({
    int? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    bool? isSent,
    Map<String, dynamic>? extraData,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? sentAt,
  }) {
    return TaskSphereNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  NotificationType get notificationType => NotificationType.fromString(type);

  @override
  String toString() {
    return 'TaskSphereNotification(id: $id, type: $type, title: $title, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskSphereNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
