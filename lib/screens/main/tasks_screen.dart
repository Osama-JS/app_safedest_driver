import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/TaskController.dart';
import '../../models/task.dart';
import '../../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskController _taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    // Load all task types
    await Future.wait([
      _taskController.getTasks(status: 'pending', refresh: true),
      _taskController.getTasks(status: 'in_progress', refresh: true),
      _taskController.getTasks(status: 'completed', refresh: true),
    ]);
  }

  Future<void> _refreshTasks() async {
    // Refresh based on current tab
    switch (_tabController.index) {
      case 0: // Available tasks
        await _taskController.getTasks(status: 'pending', refresh: true);
        break;
      case 1: // Current tasks
        await _taskController.getTasks(status: 'in_progress', refresh: true);
        break;
      case 2: // Completed tasks
        await _taskController.getTasks(status: 'completed', refresh: true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tasks'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTasks,
            tooltip: 'refreshTasks'.tr,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'availableTasks'.tr),
            Tab(text: 'currentTasks'.tr),
            Tab(text: 'completedTasks'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableTasks(),
          _buildCurrentTasks(),
          _buildCompletedTasks(),
        ],
      ),
    );
  }

  Widget _buildAvailableTasks() {
    return Obx(() {
      final availableTasks = _taskController.availableTasks;

      if (_taskController.isLoading.value && availableTasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('loadingTasks'.tr),
            ],
          ),
        );
      }

      if (_taskController.hasError && availableTasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _taskController.errorMessage.value.isNotEmpty
                    ? _taskController.errorMessage.value
                    : 'unexpectedError'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTasks,
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      if (availableTasks.isEmpty) {
        return RefreshIndicator(
          onRefresh: _refreshTasks,
          child: ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'noAvailableTasks'.tr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'noAvailableTasksDescription'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _refreshTasks,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: availableTasks.length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: availableTasks[index],
              onAccept: (task) => _acceptTask(task),
              onReject: (task) => _rejectTask(task),
            );
          },
        ),
      );
    });
  }

  Widget _buildCurrentTasks() {
    return Obx(() {
      final currentTasks = _taskController.activeTasks;

      if (_taskController.isLoading.value && currentTasks.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (currentTasks.isEmpty) {
        return _buildEmptyState('noCurrentTasks'.tr);
      }

      return RefreshIndicator(
        onRefresh: _refreshTasks,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: currentTasks.length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: currentTasks[index],
              onStatusUpdate: (task, status) =>
                  _updateTaskStatus(task, status),
            );
          },
        ),
      );
    });
  }

  Widget _buildCompletedTasks() {
    return Obx(() {
      final completedTasks = _taskController.taskHistory;

      if (_taskController.isLoading.value && completedTasks.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (completedTasks.isEmpty) {
        return _buildEmptyState('noCompletedTasks'.tr);
      }

      return RefreshIndicator(
        onRefresh: () => _taskController.getTasks(
            status: 'completed', refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedTasks.length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: completedTasks[index],
              isCompleted: true,
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptTask(Task task) async {
    final response = await _taskController.acceptTask(task.id);

    if (response.isSuccess) {
      Get.snackbar(
        'successTitle'.tr,
        'task_accepted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'errorTitle'.tr,
        response.errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _rejectTask(Task task) async {
    final response = await _taskController.rejectTask(task.id);

    if (response.isSuccess) {
      Get.snackbar(
        'successTitle'.tr,
        'task_rejected'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'errorTitle'.tr,
        response.errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateTaskStatus(Task task, String status) async {
    final response = await _taskController.updateStatus(task.id, status);

    if (response.isSuccess) {
      Get.snackbar(
        'successTitle'.tr,
        'taskStatusUpdated'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'errorTitle'.tr,
        response.errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
