import 'api_client.dart';
import '../models/task.dart';

class TaskService {
  // Get tasks with optional filtering
  Future<TaskListResult> getTasks({
    String? filter, // 'all', 'sent', 'received'
    String? status, // 'pending', 'in_progress', 'completed', 'cancelled'
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      String endpoint = '/api/tasks/?';
      
      if (filter != null) {
        endpoint += 'filter=$filter';
      }
      
      // if (status != null) {
      //   endpoint += '&status=$status';
      // }

      final response = await ApiClient.get(endpoint);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        
        final tasks = results
            .map((taskData) => Task.fromJson(taskData as Map<String, dynamic>))
            .toList();

        return TaskListResult(
          success: true,
          tasks: tasks,
          count: data['count'] as int? ?? 0,
          next: data['next'] as String?,
          previous: data['previous'] as String?,
        );
      } else {
        return TaskListResult(
          success: false,
          message: response.message,
          tasks: [],
        );
      }
    } catch (e) {
      return TaskListResult(
        success: false,
        message: 'Failed to fetch tasks: ${e.toString()}',
        tasks: [],
      );
    }
  }

  // Create a new task
  Future<TaskResult> createTask(TaskRequest taskRequest) async {
    try {
      final response = await ApiClient.post('/api/tasks/create/', body: taskRequest.toJson());

      if (response.success && response.data != null) {
        final task = Task.fromJson(response.data as Map<String, dynamic>);
        return TaskResult(
          success: true,
          message: 'Task created successfully',
          task: task,
        );
      } else {
        return TaskResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return TaskResult(
        success: false,
        message: 'Failed to create task: ${e.toString()}',
      );
    }
  }

  // Get task details
  Future<TaskResult> getTask(int taskId) async {
    try {
      final response = await ApiClient.get('/api/tasks/$taskId/');

      if (response.success && response.data != null) {
        final task = Task.fromJson(response.data as Map<String, dynamic>);
        return TaskResult(
          success: true,
          task: task,
        );
      } else {
        return TaskResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return TaskResult(
        success: false,
        message: 'Failed to fetch task: ${e.toString()}',
      );
    }
  }

  // Update task
  Future<TaskResult> updateTask(int taskId, Map<String, dynamic> updates) async {
    try {
      final response = await ApiClient.patch('/api/tasks/$taskId/', body: updates);

      if (response.success && response.data != null) {
        final task = Task.fromJson(response.data as Map<String, dynamic>);
        return TaskResult(
          success: true,
          message: 'Task updated successfully',
          task: task,
        );
      } else {
        return TaskResult(
          success: false,
          message: response.message,
        );
      }
    } catch (e) {
      return TaskResult(
        success: false,
        message: 'Failed to update task: ${e.toString()}',
      );
    }
  }

  // Delete task
  Future<bool> deleteTask(int taskId) async {
    try {
      final response = await ApiClient.delete('/api/tasks/$taskId/');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // Get dashboard statistics
  Future<DashboardStats?> getDashboardStats() async {
    try {
      final response = await ApiClient.get('/api/tasks/dashboard/stats/');

      if (response.success && response.data != null) {
        return DashboardStats.fromJson(response.data as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get upcoming tasks
  Future<List<Task>> getUpcomingTasks() async {
    try {
      final response = await ApiClient.get('/api/tasks/upcoming/');

      if (response.success && response.data != null) {
        final List<dynamic> tasksData = response.data as List<dynamic>;
        return tasksData
            .map((taskData) => Task.fromJson(taskData as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    try {
      final response = await ApiClient.get('/api/tasks/overdue/');

      if (response.success && response.data != null) {
        final List<dynamic> tasksData = response.data as List<dynamic>;
        return tasksData
            .map((taskData) => Task.fromJson(taskData as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get calendar tasks
  Future<List<Task>> getCalendarTasks(DateTime startDate, DateTime endDate) async {
    try {
      final start = startDate.toIso8601String().split('T')[0];
      final end = endDate.toIso8601String().split('T')[0];
      
      final response = await ApiClient.get('/api/tasks/calendar/?start=$start&end=$end');

      if (response.success && response.data != null) {
        final List<dynamic> tasksData = response.data as List<dynamic>;
        return tasksData
            .map((taskData) => Task.fromJson(taskData as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}

class TaskResult {
  final bool success;
  final String? message;
  final Task? task;

  TaskResult({
    required this.success,
    this.message,
    this.task,
  });
}

class TaskListResult {
  final bool success;
  final String? message;
  final List<Task> tasks;
  final int? count;
  final String? next;
  final String? previous;

  TaskListResult({
    required this.success,
    this.message,
    required this.tasks,
    this.count,
    this.next,
    this.previous,
  });
}

class DashboardStats {
  final int totalTasks;
  final int pendingTasks;
  final int inProgressTasks;
  final int completedTasks;
  final int overdueTasks;
  final int sentTasks;
  final int receivedTasks;

  DashboardStats({
    required this.totalTasks,
    required this.pendingTasks,
    required this.inProgressTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.sentTasks,
    required this.receivedTasks,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalTasks: json['total_tasks'] as int? ?? 0,
      pendingTasks: json['pending_tasks'] as int? ?? 0,
      inProgressTasks: json['in_progress_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      overdueTasks: json['overdue_tasks'] as int? ?? 0,
      sentTasks: json['sent_tasks'] as int? ?? 0,
      receivedTasks: json['received_tasks'] as int? ?? 0,
    );
  }
}
