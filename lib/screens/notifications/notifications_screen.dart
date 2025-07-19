import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/notification_service.dart';
import '../../models/notification.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_navigation.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  final _notificationService = NotificationService();
  late TabController _tabController;

  List<TaskSphereNotification> _allNotifications = [];
  List<TaskSphereNotification> _unreadNotifications = [];

  bool _isLoading = true;
  NotificationStats? _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    print('🔔 Loading notifications...');
    setState(() {
      _isLoading = true;
    });

    try {
      // Load notifications and stats
      print('🔔 Loading all notifications...');
      final allResult = await _notificationService.getNotifications();
      print(
          '🔔 All notifications result: success=${allResult.success}, count=${allResult.notifications.length}');

      print('🔔 Loading unread notifications...');
      final unreadResult =
          await _notificationService.getNotifications(filter: 'unread');
      print(
          '🔔 Unread notifications result: success=${unreadResult.success}, count=${unreadResult.notifications.length}');

      print('📊 Loading notification stats...');
      final stats = await _notificationService.getNotificationStats();
      print('📊 Stats loaded: ${stats != null ? "success" : "failed"}');

      if (allResult.notifications.isNotEmpty) {
        print('📋 Notification details:');
        for (var notif in allResult.notifications.take(3)) {
          print(
              '   - "${notif.title}": ${notif.message} (Read: ${notif.isRead})');
        }
      } else {
        print('📭 No notifications found');
        if (!allResult.success) {
          print('❌ Notifications error: ${allResult.message}');
        }
      }

      if (mounted) {
        setState(() {
          _allNotifications = allResult.notifications;
          _unreadNotifications = unreadResult.notifications;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(TaskSphereNotification notification) async {
    if (notification.isRead) return;

    try {
      await _notificationService.markAsRead(notification.id);
      _loadNotifications(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success) {
        _loadNotifications(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All notifications marked as read'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_stats != null && _stats!.unreadNotifications > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark All Read',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All',
              icon: _stats != null && _stats!.totalNotifications > 0
                  ? Badge(
                      label: Text(_stats!.totalNotifications.toString()),
                      child: const Icon(Icons.notifications),
                    )
                  : const Icon(Icons.notifications),
            ),
            Tab(
              text: 'Unread',
              icon: _stats != null && _stats!.unreadNotifications > 0
                  ? Badge(
                      label: Text(_stats!.unreadNotifications.toString()),
                      child: const Icon(Icons.notifications_active),
                    )
                  : const Icon(Icons.notifications_active),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(_allNotifications),
                _buildNotificationList(_unreadNotifications),
              ],
            ),
      bottomNavigationBar: const TaskSphereBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildNotificationList(List<TaskSphereNotification> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(TaskSphereNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.notificationType)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.notificationType),
                  color: _getNotificationColor(notification.notificationType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatNotificationTime(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskReceived:
        return AppTheme.primaryColor;
      case NotificationType.taskUpdated:
        return AppTheme.secondaryColor;
      case NotificationType.taskCompleted:
        return AppTheme.successColor;
      case NotificationType.taskReminder:
        return AppTheme.warningColor;
      case NotificationType.taskOverdue:
        return AppTheme.errorColor;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.taskReceived:
        return Icons.task_alt;
      case NotificationType.taskUpdated:
        return Icons.update;
      case NotificationType.taskCompleted:
        return Icons.check_circle;
      case NotificationType.taskReminder:
        return Icons.schedule;
      case NotificationType.taskOverdue:
        return Icons.warning;
      case NotificationType.system:
        return Icons.info;
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }
}
