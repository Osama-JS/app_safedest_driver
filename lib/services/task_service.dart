import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/task.dart';

import 'api_service.dart';
import 'auth_service.dart';

class TaskService extends ChangeNotifier {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<Task> _tasks = [];
  List<Task> _availableTasks = [];
  List<Task> _activeTasks = [];
  List<Task> _taskHistory = [];
  Task? _currentTask;
  Task? _pendingTask;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;

  // Getters
  List<Task> get tasks => _tasks;
  List<Task> get taskHistory => _taskHistory;
  Task? get currentTask => _currentTask;
  Task? get pendingTask => _pendingTask;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  bool get isEmpty => _tasks.isEmpty && !_isLoading;
  bool get hasData => _tasks.isNotEmpty;

  // Get tasks with optional filtering
  Future<ApiResponse<TaskListResponse>> getTasks({
    String? status,
    int page = 1,
    int perPage = 10,
    bool refresh = false,
  }) async {
    if (page == 1 || refresh) {
      _setLoading(true);
      _clearError();
    }

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (status != null) 'status': status,
      };

      debugPrint('Fetching tasks with params: $queryParams');

      final response = await _apiService.get<TaskListResponse>(
        AppConfig.tasksEndpoint,
        queryParams: queryParams,
        fromJson: (data) {
          // Handle different response formats consistently
          if (data['data'] != null && data['data']['tasks'] != null) {
            return TaskListResponse.fromJson(data['data']);
          } else if (data['tasks'] != null) {
            return TaskListResponse.fromJson(data);
          } else {
            return TaskListResponse.fromJson(data['data'] ?? data);
          }
        },
      );

      if (response.isSuccess && response.data != null) {
        final newTasks = response.data!.tasks;
        debugPrint(
            'Received ${newTasks.length} tasks from API for status: $status');

        // Store tasks based on status
        if (status == 'pending') {
          if (page == 1 || refresh) {
            _availableTasks = newTasks;
          } else {
            _availableTasks.addAll(newTasks);
          }
        } else if (status == 'in_progress') {
          if (page == 1 || refresh) {
            _activeTasks = newTasks;
          } else {
            _activeTasks.addAll(newTasks);
          }
        } else if (status == 'completed') {
          if (page == 1 || refresh) {
            _taskHistory = newTasks;
          } else {
            _taskHistory.addAll(newTasks);
          }
        } else {
          // Default behavior for general tasks
          if (page == 1 || refresh) {
            _tasks = newTasks;
          } else {
            _tasks.addAll(newTasks);
          }
        }

        _clearError();
        notifyListeners();
      } else {
        _setError(response.errorMessage ?? 'فشل في جلب المهام');
        debugPrint('API Error: ${response.errorMessage}');
      }

      return response;
    } catch (e) {
      final errorMsg = 'فشل في جلب المهام: $e';
      _setError(errorMsg);
      debugPrint('Exception in getTasks: $e');

      return ApiResponse<TaskListResponse>(
        success: false,
        message: errorMsg,
      );
    } finally {
      if (page == 1 || refresh) {
        _setLoading(false);
      }
    }
  }

  // Get specific task details
  Future<ApiResponse<Task>> getTaskDetails(int taskId) async {
    try {
      final response = await _apiService.get<Task>(
        '${AppConfig.taskDetailsEndpoint}/$taskId',
        fromJson: (data) => Task.fromJson(data['data']['task']),
      );

      if (response.isSuccess && response.data != null) {
        // Update task in local list if exists
        final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          _tasks[taskIndex] = response.data!;
          notifyListeners();
        }
      }

      return response;
    } catch (e) {
      return ApiResponse<Task>(
        success: false,
        message: 'فشل في جلب تفاصيل المهمة: $e',
      );
    }
  }

  // Accept task
  Future<ApiResponse<Task>> acceptTask(int taskId) async {
    try {
      final response = await _apiService.post<Task>(
        AppConfig.getTaskEndpoint(taskId, 'accept'),
        fromJson: (data) {
          // Handle both response formats
          if (data['task'] != null) {
            return Task.fromJson(data['task']);
          } else if (data['data'] != null && data['data']['task'] != null) {
            return Task.fromJson(data['data']['task']);
          } else {
            // Create a basic task object from the response
            return Task.fromJson({
              'id': taskId,
              'status': data['task']?['status'] ?? 'accepted',
              'total_price': 0.0,
              'commission': 0.0,
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        },
      );

      if (response.isSuccess && response.data != null) {
        final acceptedTask = response.data!;

        // Remove from available tasks
        _availableTasks.removeWhere((task) => task.id == acceptedTask.id);

        // Add to active tasks if not already there
        if (!_activeTasks.any((task) => task.id == acceptedTask.id)) {
          _activeTasks.insert(0, acceptedTask);
        }

        // Update in main tasks list
        await _updateTaskInList(acceptedTask);

        // Set as current task
        _currentTask = acceptedTask;

        debugPrint(
            'Task ${acceptedTask.id} accepted and moved to active tasks');
        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<Task>(
        success: false,
        message: 'فشل في قبول المهمة: $e',
      );
    }
  }

  // Reject task
  Future<ApiResponse<void>> rejectTask(int taskId, {String? reason}) async {
    try {
      final response = await _apiService.post<void>(
        AppConfig.getTaskEndpoint(taskId, 'reject'),
        body: {
          if (reason != null) 'reason': reason,
        },
        fromJson: null,
      );

      if (response.isSuccess) {
        // Remove task from all lists
        _tasks.removeWhere((task) => task.id == taskId);
        _availableTasks.removeWhere((task) => task.id == taskId);
        _activeTasks.removeWhere((task) => task.id == taskId);

        debugPrint('Task $taskId rejected and removed from all lists');
        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'فشل في رفض المهمة: $e',
      );
    }
  }

  // Cancel task (request cancellation)
  Future<ApiResponse<void>> cancelTask(int taskId, String reason) async {
    try {
      final response = await _apiService.post<void>(
        AppConfig.getTaskEndpoint(taskId, 'cancel'),
        body: {
          'reason': reason,
        },
        fromJson: null,
      );

      if (response.isSuccess) {
        // Update local task state instead of removing it
        int index = _activeTasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          _activeTasks[index] = _activeTasks[index].copyWith(
            driverCancel: true,
            driverCancelReason: reason,
          );
        }

        if (_currentTask?.id == taskId) {
          _currentTask = _currentTask?.copyWith(
            driverCancel: true,
            driverCancelReason: reason,
          );
        }

        debugPrint('Task $taskId cancellation requested');
        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'فشل في طلب إلغاء المهمة: $e',
      );
    }
  }

  // Update task status
  Future<ApiResponse<Task>> updateTaskStatus(
    int taskId,
    String status, {
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{
        'status': status,
        if (notes != null) 'notes': notes,
        if (latitude != null && longitude != null)
          'location': {
            'latitude': latitude,
            'longitude': longitude,
          },
      };

      final response = await _apiService.put<Task>(
        '${AppConfig.updateTaskStatusEndpoint}/$taskId/status',
        body: body,
        fromJson: (data) => Task.fromJson(data['task']),
      );

      if (response.isSuccess && response.data != null) {
        await _updateTaskInList(response.data!);

        // Update current task if it's the same
        if (_currentTask?.id == taskId) {
          _currentTask = response.data;
        }

        // If task is completed, move to history
        if (status == TaskStatus.completed.value) {
          _currentTask = null;
          _moveTaskToHistory(response.data!);
        }

        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<Task>(
        success: false,
        message: 'فشل في تحديث حالة المهمة: $e',
      );
    }
  }

  // Get task history
  Future<ApiResponse<TaskListResponse>> getTaskHistory({
    int page = 1,
    int perPage = 20,
    String? from,
    String? to,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      };

      debugPrint('Fetching task history with params: $queryParams');

      final response = await _apiService.get<TaskListResponse>(
        AppConfig.taskHistoryEndpoint,
        queryParams: queryParams,
        fromJson: (data) {
          // Helper function to parse int
          int? parseInt(dynamic value) {
            if (value == null) return null;
            if (value is int) return value;
            if (value is String) return int.tryParse(value);
            return null;
          }

          // Handle different response formats
          if (data['tasks'] != null) {
            // Direct format: { "tasks": [...], "pagination": {...} }
            final pagination = data['pagination'] ?? {};
            return TaskListResponse(
              tasks: (data['tasks'] as List)
                  .map((task) => Task.fromJson(task))
                  .toList(),
              currentPage: parseInt(pagination['current_page']) ?? 1,
              lastPage: parseInt(pagination['last_page']) ?? 1,
              total: parseInt(pagination['total']) ?? 0,
            );
          } else if (data['data'] != null) {
            // Nested format: { "data": { "tasks": [...] } }
            return TaskListResponse.fromJson(data['data']);
          } else {
            // Fallback
            return TaskListResponse.fromJson(data);
          }
        },
      );

      if (response.isSuccess && response.data != null) {
        final newTasks = response.data!.tasks;
        debugPrint('Received ${newTasks.length} completed tasks from API');

        if (page == 1) {
          _taskHistory = newTasks;
        } else {
          _taskHistory.addAll(newTasks);
        }
        notifyListeners();
      }

      return response;
    } catch (e) {
      return ApiResponse<TaskListResponse>(
        success: false,
        message: 'فشل في جلب تاريخ المهام: $e',
      );
    }
  }

  // Get specific task history/logs
  Future<ApiResponse<List<TaskLog>>> getTaskLogs(int taskId) async {
    try {
      final response = await _apiService.get<List<TaskLog>>(
        '${AppConfig.tasksEndpoint}/$taskId/logs',
        fromJson: (data) {
          // البيانات ترجع في data.logs مباشرة (data هنا هو محتوى response.data من API)
          if (data != null && data['logs'] is List) {
            return (data['logs'] as List)
                .map((log) => TaskLog.fromJson(log))
                .toList();
          }
          return <TaskLog>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<TaskLog>>(
        success: false,
        message: 'فشل في جلب سجل المهمة: $e',
      );
    }
  }

  // Add note to task
  Future<ApiResponse<bool>> addTaskNote(int taskId, String note,
      {String? filePath}) async {
    try {
      final data = {
        'note': note,
        'type': 'driver_note',
      };

      ApiResponse<bool> response;

      if (filePath != null) {
        // Upload with file
        response = await _apiService.uploadFile<bool>(
          '${AppConfig.tasksEndpoint}/$taskId/notes',
          File(filePath),
          fields: data,
          fromJson: (data) => data['success'] == true,
        );
      } else {
        // Just text note
        response = await _apiService.post<bool>(
          '${AppConfig.tasksEndpoint}/$taskId/notes',
          body: data,
          fromJson: (data) => data['success'] == true,
        );
      }

      return response;
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'فشل في إضافة الملاحظة: $e',
      );
    }
  }

  // Get pending tasks
  Future<ApiResponse<TaskListResponse>> getPendingTasks({
    int page = 1,
    int perPage = 10,
  }) async {
    return getTasks(
      status: TaskStatus.assign.value,
      page: page,
      perPage: perPage,
    );
  }

  // Get accepted tasks
  Future<ApiResponse<TaskListResponse>> getAcceptedTasks({
    int page = 1,
    int perPage = 10,
  }) async {
    return getTasks(
      status: TaskStatus.started.value,
      page: page,
      perPage: perPage,
    );
  }

  // Get in-progress tasks
  Future<ApiResponse<TaskListResponse>> getInProgressTasks({
    int page = 1,
    int perPage = 10,
  }) async {
    return getTasks(
      status: 'in_progress',
      page: page,
      perPage: perPage,
    );
  }

  // Refresh tasks
  Future<void> refreshTasks() async {
    await getTasks(page: 1);
  }

  // Clear tasks
  void clearTasks() {
    _tasks.clear();
    _availableTasks.clear();
    _activeTasks.clear();
    _taskHistory.clear();
    _currentTask = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _hasError = true;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _hasError = false;
    notifyListeners();
  }

  Future<void> _updateTaskInList(Task updatedTask) async {
    // Update in main tasks list
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = updatedTask;
    }

    // Update in available tasks list
    final availableIndex =
        _availableTasks.indexWhere((task) => task.id == updatedTask.id);
    if (availableIndex != -1) {
      _availableTasks[availableIndex] = updatedTask;
    }

    // Update in active tasks list
    final activeIndex =
        _activeTasks.indexWhere((task) => task.id == updatedTask.id);
    if (activeIndex != -1) {
      _activeTasks[activeIndex] = updatedTask;
    }
  }

  void _moveTaskToHistory(Task task) {
    _tasks.removeWhere((t) => t.id == task.id);
    if (!_taskHistory.any((t) => t.id == task.id)) {
      _taskHistory.insert(0, task);
    }
  }

  // Get task by ID
  Task? getTaskById(int taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Get tasks by status
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status.value).toList();
  }

  // Check if driver has active task
  bool get hasActiveTask => _currentTask != null;

  // Get available tasks (pending for this driver)
  List<Task> get availableTasks {
    return _availableTasks;
  }

  // Get active tasks
  List<Task> get activeTasks {
    return _activeTasks;
  }

  // Get task count by status
  int getTaskCountByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status.value).length;
  }

  // Check for pending tasks assigned to driver
  Future<void> checkPendingTasks() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/driver/pending-task',
        fromJson: (data) => data,
      );

      if (response.isSuccess && response.data != null) {
        final taskData = response.data!['task'];
        if (taskData != null) {
          _pendingTask = Task.fromJson(taskData);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error checking pending tasks: $e');
    }
  }

  // Accept pending task
  Future<void> acceptPendingTask() async {
    if (_pendingTask == null) return;

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/driver/accept-task',
        body: {'task_id': _pendingTask!.id},
        fromJson: (data) => data,
      );

      if (response.isSuccess) {
        _currentTask = _pendingTask;
        _pendingTask = null;
        notifyListeners();

        // Refresh tasks list
        await getTasks();
      }
    } catch (e) {
      debugPrint('Error accepting task: $e');
    }
  }

  // Reject pending task
  Future<void> rejectPendingTask() async {
    if (_pendingTask == null) return;

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/driver/reject-task',
        body: {'task_id': _pendingTask!.id},
        fromJson: (data) => data,
      );

      if (response.isSuccess) {
        _pendingTask = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error rejecting task: $e');
    }
  }
}
