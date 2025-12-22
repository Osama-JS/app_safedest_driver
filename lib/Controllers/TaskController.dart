import 'dart:io';
import 'package:get/get.dart';
import '../Helpers/TaskHelper.dart';
import '../models/task.dart';
import '../models/api_response.dart';

class TaskController extends GetxController {
  final TaskHelper _taskHelper = TaskHelper();

  // Reactive state
  final RxList<Task> availableTasks = <Task>[].obs;
  final RxList<Task> activeTasks = <Task>[].obs;
  final RxList<Task> taskHistory = <Task>[].obs;

  final Rxn<Task> currentTask = Rxn<Task>();
  final Rxn<Task> pendingTask = Rxn<Task>();

  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = "".obs;

  RxBool get isLoading => _isLoading;
  RxString get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.value.isNotEmpty;

  // Added getters requested by user
  List<Task> get tasks => activeTasks; // Defaulting to active tasks

  @override
  void onInit() {
    super.onInit();
  }

  // Fetch tasks (Alias for getTasks or specific implementation)
  Future<void> fetchTasks({
    String? status,
    int page = 1,
    int perPage = 20,
    bool refresh = false,
  }) async => await getTasks(status: status, page: page, perPage: perPage, refresh: refresh);

  // Main getTasks method used by UI
  Future<void> getTasks({
    String? status,
    int page = 1,
    int perPage = 20,
    bool refresh = false,
  }) async {
    if (status == 'pending') {
      await fetchAvailableTasks(refresh: refresh);
    } else if (status == 'in_progress' || status == 'active') {
      await fetchActiveTasks(refresh: refresh);
    } else if (status == 'completed') {
      await fetchHistory(page: page, refresh: refresh);
    }
  }

  // Added checkPendingTasks requested by user
  Future<void> checkPendingTasks() async => await fetchAvailableTasks();

  // Fetch all tasks
  Future<void> fetchAllTasks({bool refresh = false}) async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchAvailableTasks(refresh: refresh),
        fetchActiveTasks(refresh: refresh),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch available tasks (pending)
  Future<void> fetchAvailableTasks({bool refresh = false}) async {
    final response = await _taskHelper.getTasks(status: 'pending', page: 1);
    if (response.isSuccess && response.data != null) {
      availableTasks.assignAll(response.data!.tasks);
    }
  }

  // Fetch active tasks (in_progress / started)
  Future<void> fetchActiveTasks({bool refresh = false}) async {
    final response = await _taskHelper.getTasks(status: 'in_progress', page: 1);
    if (response.isSuccess && response.data != null) {
      activeTasks.assignAll(response.data!.tasks);
      if (activeTasks.isNotEmpty) {
        currentTask.value = activeTasks.first;
      }
    }
  }

  // Fetch history
  Future<void> fetchHistory({int page = 1, bool refresh = false}) async {
    if (page == 1) isLoading.value = true;
    try {
      final response = await _taskHelper.getTaskHistory(page: page);
      if (response.isSuccess && response.data != null) {
        if (page == 1 || refresh) {
          taskHistory.assignAll(response.data!.tasks);
        } else {
          taskHistory.addAll(response.data!.tasks);
        }
      }
    } finally {
      if (page == 1) isLoading.value = false;
    }
  }

  // Accept task
  Future<ApiResponse<Task>> acceptTask(int taskId) async {
    _isLoading.value = true;
    try {
      final response = await _taskHelper.acceptTask(taskId);
      if (response.isSuccess && response.data != null) {
        availableTasks.removeWhere((t) => t.id == taskId);
        activeTasks.insert(0, response.data!);
        currentTask.value = response.data;
      }
      return response;
    } finally {
      _isLoading.value = false;
    }
  }

  // Alias requested by user - can be called with or without ID
  Future<ApiResponse<Task>> acceptPendingTask([int? taskId]) async {
    final id = taskId ?? pendingTask.value?.id;
    if (id == null) return ApiResponse(success: false, message: 'no_task_to_accept'.tr);
    return await acceptTask(id);
  }

  // Reject task
  Future<ApiResponse<void>> rejectTask(int taskId, {String? reason}) async {
    _isLoading.value = true;
    try {
      final response = await _taskHelper.rejectTask(taskId, reason: reason);
      if (response.isSuccess) {
        availableTasks.removeWhere((t) => t.id == taskId);
        activeTasks.removeWhere((t) => t.id == taskId);
        if (currentTask.value?.id == taskId) currentTask.value = null;
      }
      return response;
    } finally {
      _isLoading.value = false;
    }
  }

  // Alias requested by user - can be called with or without ID
  Future<ApiResponse<void>> rejectPendingTask([int? taskId, String? reason]) async {
    final id = taskId ?? pendingTask.value?.id;
    if (id == null) return ApiResponse(success: false, message: 'no_task_to_reject'.tr);
    return await rejectTask(id, reason: reason);
  }

  // Update status
  Future<ApiResponse<Task>> updateStatus(int taskId, String status, {String? notes}) async {
    isLoading.value = true;
    try {
      final response = await _taskHelper.updateTaskStatus(taskId, status, notes: notes);
      if (response.isSuccess && response.data != null) {
        final updatedTask = response.data!;

        // Update in active tasks
        int index = activeTasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          if (status == 'completed' || status == 'cancelled') {
            activeTasks.removeAt(index);
            taskHistory.insert(0, updatedTask);
            if (currentTask.value?.id == taskId) currentTask.value = null;
          } else {
            activeTasks[index] = updatedTask;
            if (currentTask.value?.id == taskId) currentTask.value = updatedTask;
          }
        }
      }
      return response;
    } finally {
      isLoading.value = false;
    }
  }

  // Get task details
  Future<ApiResponse<Task>> getTaskDetails(int taskId) async {
    return await _taskHelper.getTaskDetails(taskId);
  }

  // Get task logs
  Future<ApiResponse<List<TaskLog>>> getTaskLogs(int taskId) async {
    return await _taskHelper.getTaskLogs(taskId);
  }

  // Add task note
  Future<ApiResponse<bool>> addTaskNote(int taskId, String note, {String? filePath}) async {
    File? file;
    if (filePath != null && filePath.isNotEmpty) {
      file = File(filePath);
    }
    return await _taskHelper.addTaskNote(taskId, note, imageFile: file);
  }

  // Get task count by status
  int getTaskCountByStatus(String status) {
    if (status == 'pending' || status == 'assign') return availableTasks.length;
    if (status == 'active' || status == 'in_progress' || status == 'accepted') return activeTasks.length;
    if (status == 'completed') return taskHistory.length;
    return 0;
  }

  // Reset all
  void reset() {
    availableTasks.clear();
    activeTasks.clear();
    taskHistory.clear();
    currentTask.value = null;
    pendingTask.value = null;
  }
}
