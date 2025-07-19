import 'api_client.dart';
import '../models/notification.dart';

class NotificationService {
  // Get notifications with optional filtering
  Future<NotificationListResult> getNotifications({
    String? filter, // 'all', 'unread', 'read'
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      String endpoint = '/api/notifications/';

      if (filter != null && filter != 'all') {
        endpoint += '?filter=$filter';
      }

      print('NotificationService: Fetching notifications from $endpoint');
      final response = await ApiClient.get(endpoint);
      print('NotificationService: Response status: ${response.success}');

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        print('NotificationService: Found ${results.length} notifications');

        final notifications = results
            .map((notificationData) => TaskSphereNotification.fromJson(
                notificationData as Map<String, dynamic>))
            .toList();

        print(
            'NotificationService: Successfully parsed ${notifications.length} notifications');

        return NotificationListResult(
          success: true,
          notifications: notifications,
          count: data['count'] as int? ?? 0,
          next: data['next'] as String?,
          previous: data['previous'] as String?,
        );
      } else {
        return NotificationListResult(
          success: false,
          message: response.message,
          notifications: [],
        );
      }
    } catch (e) {
      return NotificationListResult(
        success: false,
        message: 'Failed to fetch notifications: ${e.toString()}',
        notifications: [],
      );
    }
  }

  // Get notification details
  Future<NotificationResult> getNotification(int notificationId) async {
    try {
      final response =
          await ApiClient.get('/api/notifications/$notificationId/');

      if (response.success && response.data != null) {
        final notification = TaskSphereNotification.fromJson(
            response.data as Map<String, dynamic>);
        return NotificationResult(
          success: true,
          notification: notification,
        );
      } else {
        return NotificationResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return NotificationResult(
        success: false,
        message: 'Failed to fetch notification: ${e.toString()}',
      );
    }
  }

  // Mark notification as read
  Future<NotificationResult> markAsRead(int notificationId) async {
    try {
      final response =
          await ApiClient.patch('/api/notifications/$notificationId/', body: {
        'is_read': true,
      });

      if (response.success && response.data != null) {
        final notification = TaskSphereNotification.fromJson(
            response.data as Map<String, dynamic>);
        return NotificationResult(
          success: true,
          message: 'Notification marked as read',
          notification: notification,
        );
      } else {
        return NotificationResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return NotificationResult(
        success: false,
        message: 'Failed to mark notification as read: ${e.toString()}',
      );
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response =
          await ApiClient.post('/api/notifications/mark-all-read/');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // Clear read notifications
  Future<bool> clearReadNotifications() async {
    try {
      final response = await ApiClient.delete('/api/notifications/clear-read/');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // Get notification statistics
  Future<NotificationStats?> getNotificationStats() async {
    try {
      final response = await ApiClient.get('/api/notifications/stats/');

      if (response.success && response.data != null) {
        return NotificationStats.fromJson(
            response.data as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

class NotificationResult {
  final bool success;
  final String? message;
  final TaskSphereNotification? notification;

  NotificationResult({
    required this.success,
    this.message,
    this.notification,
  });
}

class NotificationListResult {
  final bool success;
  final String? message;
  final List<TaskSphereNotification> notifications;
  final int? count;
  final String? next;
  final String? previous;

  NotificationListResult({
    required this.success,
    this.message,
    required this.notifications,
    this.count,
    this.next,
    this.previous,
  });
}

class NotificationStats {
  final int totalNotifications;
  final int unreadNotifications;
  final int recentNotifications;

  NotificationStats({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.recentNotifications,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalNotifications: json['total_notifications'] as int? ?? 0,
      unreadNotifications: json['unread_notifications'] as int? ?? 0,
      recentNotifications: json['recent_notifications'] as int? ?? 0,
    );
  }
}
