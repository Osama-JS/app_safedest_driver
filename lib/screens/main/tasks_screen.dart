import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';
import '../../models/task.dart';
import '../../widgets/task_card.dart';
import '../../l10n/generated/app_localizations.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final taskService = Provider.of<TaskService>(context, listen: false);

    // Load all task types
    await Future.wait([
      taskService.getTasks(
          status: 'pending', page: 1, perPage: 20, refresh: true),
      taskService.getTasks(
          status: 'in_progress', page: 1, perPage: 20, refresh: true),
      taskService.getTasks(
          status: 'completed', page: 1, perPage: 20, refresh: true),
    ]);
  }

  Future<void> _refreshTasks() async {
    final taskService = Provider.of<TaskService>(context, listen: false);

    // Refresh based on current tab
    switch (_tabController.index) {
      case 0: // Available tasks
        await taskService.getTasks(
            status: 'pending', page: 1, perPage: 20, refresh: true);
        break;
      case 1: // Current tasks
        await taskService.getTasks(
            status: 'in_progress', page: 1, perPage: 20, refresh: true);
        break;
      case 2: // Completed tasks
        await taskService.getTasks(
            status: 'completed', page: 1, perPage: 20, refresh: true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tasks),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTasks,
            tooltip: l10n.refreshTasks,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.availableTasks),
            Tab(text: l10n.currentTasks),
            Tab(text: l10n.completedTasks),
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
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        final l10n = AppLocalizations.of(context)!;
        final availableTasks = taskService.availableTasks;

        if (taskService.isLoading && availableTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.loadingTasks),
              ],
            ),
          );
        }

        if (taskService.hasError && availableTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  taskService.errorMessage ?? l10n.unexpectedError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadTasks,
                  child: Text(l10n.retry),
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
                        l10n.noAvailableTasks,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noAvailableTasksDescription,
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
      },
    );
  }

  Widget _buildCurrentTasks() {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        final l10n = AppLocalizations.of(context)!;
        final currentTasks = taskService.activeTasks;

        if (taskService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (currentTasks.isEmpty) {
          return _buildEmptyState(l10n.noCurrentTasks);
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
      },
    );
  }

  Widget _buildCompletedTasks() {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        final l10n = AppLocalizations.of(context)!;
        final completedTasks = taskService.taskHistory;

        if (taskService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (completedTasks.isEmpty) {
          return _buildEmptyState(l10n.noCompletedTasks);
        }

        return RefreshIndicator(
          onRefresh: () => taskService.getTasks(
              status: 'completed', page: 1, perPage: 20, refresh: true),
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
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptTask(Task task) async {
    final taskService = Provider.of<TaskService>(context, listen: false);

    final response = await taskService.acceptTask(task.id);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.taskAcceptedSuccess)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.errorMessage)),
        );
      }
    }
  }

  Future<void> _rejectTask(Task task) async {
    final taskService = Provider.of<TaskService>(context, listen: false);

    final response = await taskService.rejectTask(task.id);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.taskRejected)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.errorMessage)),
        );
      }
    }
  }

  Future<void> _updateTaskStatus(Task task, String status) async {
    final taskService = Provider.of<TaskService>(context, listen: false);

    final response = await taskService.updateTaskStatus(task.id, status);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.taskStatusUpdated)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.errorMessage)),
        );
      }
    }
  }
}
