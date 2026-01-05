import 'dart:io';
import '../services/api_service.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/task.dart';

class TaskHelper {
  final ApiService _apiService = ApiService();

  // Get tasks with optional filtering
  Future<ApiResponse<TaskListResponse>> getTasks({
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (status != null) 'status': status,
    };

    return await _apiService.get<TaskListResponse>(
      AppConfig.tasksEndpoint,
      queryParams: queryParams,
      fromJson: (data) {
        if (data is List) {
          return TaskListResponse(
            tasks: data.map((json) => Task.fromJson(json)).whereType<Task>().toList(),
            currentPage: 1,
            lastPage: 1,
            total: data.length,
          );
        }
        return TaskListResponse.fromJson(data);
      },
    );
  }

  // Get specific task details
  Future<ApiResponse<Task>> getTaskDetails(int taskId) async {
    return await _apiService.get<Task>(
      '${AppConfig.taskDetailsEndpoint}/$taskId',
      fromJson: (data) => Task.fromJson(data['data']['task']),
    );
  }

  // Accept task
  Future<ApiResponse<Task>> acceptTask(int taskId) async {
    return await _apiService.post<Task>(
      AppConfig.getTaskEndpoint(taskId, 'accept'),
      fromJson: (data) {
        if (data['task'] != null) {
          return Task.fromJson(data['task']);
        } else if (data['data'] != null && data['data']['task'] != null) {
          return Task.fromJson(data['data']['task']);
        } else {
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
  }

  // Reject task
  Future<ApiResponse<void>> rejectTask(int taskId, {String? reason}) async {
    return await _apiService.post<void>(
      AppConfig.getTaskEndpoint(taskId, 'reject'),
      body: {if (reason != null) 'reason': reason},
      fromJson: (data) => null,
    );
  }

  // Update task status
  Future<ApiResponse<Task>> updateTaskStatus(
    int taskId,
    String status, {
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'status': status,
      if (notes != null) 'notes': notes,
      if (latitude != null && longitude != null)
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
    };

    return await _apiService.put<Task>(
      '${AppConfig.updateTaskStatusEndpoint}/$taskId/status',
      body: body,
      fromJson: (data) => Task.fromJson(data['task']),
    );
  }

  // Get task history
  Future<ApiResponse<TaskListResponse>> getTaskHistory({
    int page = 1,
    int perPage = 20,
    String? from,
    String? to,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };

    return await _apiService.get<TaskListResponse>(
      AppConfig.taskHistoryEndpoint,
      queryParams: queryParams,
      fromJson: (data) {
        if (data is List) {
          return TaskListResponse(
            tasks: data.map((json) => Task.fromJson(json)).whereType<Task>().toList(),
            currentPage: 1,
            lastPage: 1,
            total: data.length,
          );
        }

        if (data['tasks'] != null) {
          int? parseInt(dynamic value) {
            if (value == null) return null;
            if (value is int) return value;
            if (value is String) return int.tryParse(value);
            return null;
          }
          final pagination = data['pagination'] ?? {};
          return TaskListResponse(
            tasks: (data['tasks'] as List)
                .map((task) => Task.fromJson(task))
                .toList(),
            currentPage: parseInt(pagination['current_page']) ?? 1,
            lastPage: parseInt(pagination['last_page']) ?? 1,
            total: parseInt(pagination['total']) ?? 0,
          );
        }
        // When using standard pagination (data contains list), 'data' passed here is already the pagination object
        // containing 'data' (List) and 'current_page' etc.
        // We should NOT try to unwrap data['data'] here because that would pass a List to fromJson, causing an error.
        return TaskListResponse.fromJson(data);
      },
    );
  }

  // Get specific task history/logs
  Future<ApiResponse<List<TaskLog>>> getTaskLogs(int taskId) async {
    return await _apiService.get<List<TaskLog>>(
      '${AppConfig.tasksEndpoint}/$taskId/logs',
      fromJson: (data) {
        if (data != null && data['logs'] is List) {
          return (data['logs'] as List)
              .map((log) => TaskLog.fromJson(log))
              .toList();
        }
        return <TaskLog>[];
      },
    );
  }

  // Add note to task
  Future<ApiResponse<bool>> addTaskNote(int taskId, String note, {File? imageFile}) async {
    final data = {
      'note': note,
      'type': 'driver_note',
    };

    if (imageFile != null) {
      return await _apiService.uploadFile<bool>(
        '${AppConfig.tasksEndpoint}/$taskId/notes',
        imageFile,
        fields: data,
        fromJson: (data) => data['success'] == true,
      );
    } else {
      return await _apiService.post<bool>(
        '${AppConfig.tasksEndpoint}/$taskId/notes',
        body: data,
        fromJson: (data) => data['success'] == true,
      );
    }
  }
}
