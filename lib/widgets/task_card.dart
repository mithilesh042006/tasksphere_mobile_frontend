import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../../providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskCard extends ConsumerStatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final Function(TaskStatus)? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
  });

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: widget.task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityChip(),
                ],
              ),
              
              if (widget.task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.task.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Task metadata
              Row(
                children: [
                  // Status chip
                  _buildStatusChip(),
                  const SizedBox(width: 8),
                  
                  // Due date
                  if (widget.task.dueDate != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: widget.task.isOverdue ? AppTheme.errorColor : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDueDate(widget.task.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.task.isOverdue ? AppTheme.errorColor : Colors.grey[600],
                        fontWeight: widget.task.isOverdue ? FontWeight.w600 : null,
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  
                  // Sender/Receiver info
                  _buildUserInfo(context),
                ],
              ),
              
              // Status change buttons (only for received tasks)
              if (widget.onStatusChanged != null && _canChangeStatus() && user == widget.task.receiver) ...[
                const SizedBox(height: 12),
                _buildStatusButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    final color = AppTheme.getPriorityColor(widget.task.priority.value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        widget.task.priority.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final color = AppTheme.getStatusColor(widget.task.status.value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        widget.task.status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            widget.task.sender.fullDisplayName.isNotEmpty
                ? widget.task.sender.fullDisplayName[0].toUpperCase()
                : 'U',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.arrow_forward,
          size: 12,
          color: Colors.grey[400],
        ),
        const SizedBox(width: 4),
        CircleAvatar(
          radius: 12,
          backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
          child: Text(
            widget.task.receiver.fullDisplayName.isNotEmpty
                ? widget.task.receiver.fullDisplayName[0].toUpperCase()
                : 'U',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButtons() {
    return Row(
      children: [
        if (widget.task.status == TaskStatus.pending) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => widget.onStatusChanged!(TaskStatus.inProgress),
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('Start'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.inProgressColor,
                side: BorderSide(color: AppTheme.inProgressColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => widget.onStatusChanged!(TaskStatus.completed),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.completedColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ] else if (widget.task.status == TaskStatus.inProgress) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => widget.onStatusChanged!(TaskStatus.completed),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.completedColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _canChangeStatus() {
    return widget.task.status != TaskStatus.completed && widget.task.status != TaskStatus.cancelled;
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
}
