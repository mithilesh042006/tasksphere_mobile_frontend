import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/task_service.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../utils/theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _taskService = TaskService();
  Task? _task;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _taskService.getTask(widget.taskId);
      if (result.success && result.task != null) {
        setState(() {
          _task = result.task;
          _isLoading = false;
        });
      } else {
        _showError(result.message ?? 'Failed to load task');
      }
    } catch (e) {
      _showError('Failed to load task: ${e.toString()}');
    }
  }

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    if (_task == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final result =
          await _taskService.updateTask(_task!.id, {'status': newStatus.value});
      if (result.success) {
        setState(() {
          _task = _task!.copyWith(status: newStatus);
          _isUpdating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task status updated to ${newStatus.label}'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        _showError(result.message ?? 'Failed to update task');
      }
    } catch (e) {
      _showError('Failed to update task: ${e.toString()}');
    }
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
      _isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_task?.title ?? 'Task Details'),
        actions: [
          if (_task != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // TODO: Navigate to edit screen
                } else if (value == 'delete') {
                  _showDeleteConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppTheme.errorColor),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: AppTheme.errorColor)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Task not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : _buildTaskDetails(),
    );
  }

  Widget _buildTaskDetails() {
    final task = _task!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Priority
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              _buildPriorityChip(task.priority),
            ],
          ),

          const SizedBox(height: 16),

          // Status
          Row(
            children: [
              _buildStatusChip(task.status),
              const Spacer(),
              if (task.dueDate != null) ...[
                Icon(
                  Icons.schedule,
                  size: 16,
                  color:
                      task.isOverdue ? AppTheme.errorColor : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDueDate(task.dueDate!),
                  style: TextStyle(
                    color:
                        task.isOverdue ? AppTheme.errorColor : Colors.grey[600],
                    fontWeight: task.isOverdue ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Description
          if (task.description.isNotEmpty) ...[
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Participants
          Text(
            'Participants',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          // Sender
          _buildUserTile(
            user: task.sender,
            label: 'Sender',
            icon: Icons.send,
            color: AppTheme.primaryColor,
          ),

          const SizedBox(height: 8),

          // Receiver
          _buildUserTile(
            user: task.receiver,
            label: 'Receiver',
            icon: Icons.person,
            color: AppTheme.secondaryColor,
          ),

          const SizedBox(height: 24),

          // Notes
          if (task.notes.isNotEmpty) ...[
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                task.notes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Timestamps
          _buildTimestampSection(task),

          const SizedBox(height: 24),

          // Status Update Buttons
          if (_canUpdateStatus(task)) _buildStatusUpdateButtons(task),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    final color = AppTheme.getPriorityColor(priority.value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(priority),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    final color = AppTheme.getStatusColor(status.value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile({
    required User user,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              user.fullDisplayName.isNotEmpty
                  ? user.fullDisplayName[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  user.fullDisplayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '@${user.username} • ${user.userId}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampSection(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _buildTimestampRow('Created', task.createdAt),
        _buildTimestampRow('Last Updated', task.updatedAt),
        if (task.completedAt != null)
          _buildTimestampRow('Completed', task.completedAt!),
      ],
    );
  }

  Widget _buildTimestampRow(String label, DateTime dateTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Text(
            DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateButtons(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        if (task.status == TaskStatus.pending) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isUpdating
                      ? null
                      : () => _updateTaskStatus(TaskStatus.inProgress),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start Task'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.inProgressColor,
                    side: BorderSide(color: AppTheme.inProgressColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUpdating
                      ? null
                      : () => _updateTaskStatus(TaskStatus.completed),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.completedColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ] else if (task.status == TaskStatus.inProgress) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUpdating
                  ? null
                  : () => _updateTaskStatus(TaskStatus.completed),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Mark as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.completedColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ] else if (task.status == TaskStatus.completed) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isUpdating
                  ? null
                  : () => _updateTaskStatus(TaskStatus.inProgress),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reopen Task'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.inProgressColor,
                side: BorderSide(color: AppTheme.inProgressColor),
              ),
            ),
          ),
        ],
        if (_isUpdating) ...[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  bool _canUpdateStatus(Task task) {
    return task.status != TaskStatus.cancelled;
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.urgent:
        return Icons.priority_high;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.play_arrow;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays < 7) {
      return 'Due in ${difference.inDays} days';
    } else {
      return DateFormat('MMM dd, yyyy').format(dueDate);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
            'Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTask();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask() async {
    if (_task == null) return;

    try {
      final success = await _taskService.deleteTask(_task!.id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.pop();
        }
      } else {
        _showError('Failed to delete task');
      }
    } catch (e) {
      _showError('Failed to delete task: ${e.toString()}');
    }
  }
}
