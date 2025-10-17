import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../screens/add_task_screen.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../models/activity.dart';
import 'package:another_flushbar/flushbar.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService notificationService = NotificationService();
  late ConfettiController confettiController;

  final RxList<Task> tasks = <Task>[].obs;
  final RxList<Task> filteredTasks = <Task>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentFilter = 0.obs;
  final RxBool showCelebration = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    confettiController = ConfettiController(duration: const Duration(seconds: 1));
    loadTasks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    confettiController.dispose();
    super.onClose();
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      final fetchedTask = await _databaseHelper.getTasks();
      tasks.assignAll(fetchedTask);
      filterTasks();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      showErrorFlushBar('Failed to load tasks: $e');
    }
  }

  void filterTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<Task> tempTasks;

    if (searchQuery.value.isEmpty) {
      switch (currentFilter.value) {
        case 0: // Due
          tempTasks = tasks.where((task) {
            final isNotCompleted = !task.isCompleted;
            final hasDueDate = task.dueDate != null;
            final dueAfterOrToday = task.dueDate != null &&
                !DateTime(
                  task.dueDate!.year,
                  task.dueDate!.month,
                  task.dueDate!.day,
                ).isBefore(today);
            final reminderNotPast = !(task.reminderDate != null && task.reminderDate!.isBefore(DateTime.now()));
            return isNotCompleted && hasDueDate && dueAfterOrToday && reminderNotPast;
          }).toList();
          break;
        case 1: // Delay
          tempTasks = tasks.where((task) {
            final isNotCompleted = !task.isCompleted;
            final hasDueDate = task.dueDate != null;
            final dueBeforeToday = task.dueDate != null &&
                DateTime(
                  task.dueDate!.year,
                  task.dueDate!.month,
                  task.dueDate!.day,
                ).isBefore(today);
            final reminderInPast = task.reminderDate != null && task.reminderDate!.isBefore(DateTime.now());
            return isNotCompleted && hasDueDate && (dueBeforeToday || reminderInPast);
          }).toList();
          break;
        case 2: // Done
          tempTasks = tasks.where((task) => task.isCompleted).toList();
          break;
        default:
          tempTasks = tasks.toList();
      }
    } else {
      final query = searchQuery.value.toLowerCase();
      switch (currentFilter.value) {
        case 0: // Due
          tempTasks = tasks.where((task) =>
          !task.isCompleted &&
              task.dueDate != null &&
              !DateTime(
                task.dueDate!.year,
                task.dueDate!.month,
                task.dueDate!.day,
              ).isBefore(today) &&
              !(task.reminderDate != null && task.reminderDate!.isBefore(DateTime.now())) &&
              (task.title.toLowerCase().contains(query) ||
                  task.description.toLowerCase().contains(query))).toList();
          break;
        case 1: // Delay
          tempTasks = tasks.where((task) =>
          !task.isCompleted &&
              task.dueDate != null &&
              (DateTime(
                task.dueDate!.year,
                task.dueDate!.month,
                task.dueDate!.day,
              ).isBefore(today) ||
                  (task.reminderDate != null && task.reminderDate!.isBefore(DateTime.now()))) &&
              (task.title.toLowerCase().contains(query) ||
                  task.description.toLowerCase().contains(query))).toList();
          break;
        case 2: // Done
          tempTasks = tasks.where((task) =>
          task.isCompleted &&
              (task.title.toLowerCase().contains(query) ||
                  task.description.toLowerCase().contains(query))).toList();
          break;
        default:
          tempTasks = tasks.toList();
      }
    }

    tempTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      if (a.dueDate != null && b.dueDate != null) {
        int dateComparison = a.dueDate!.compareTo(b.dueDate!);
        if (dateComparison != 0) return dateComparison;
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }
      if (a.priority != b.priority) return b.priority.compareTo(a.priority);
      return b.createdAt.compareTo(a.createdAt);
    });
    print('temp task is ${tempTasks.toList()}');
    filteredTasks.assignAll(tempTasks);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterTasks();
  }

  void setFilter(int index) {
    currentFilter.value = index;
    filterTasks();
  }

  Future<void> toggleTask(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      tasks[idx] = updatedTask;
      filterTasks();
      await _databaseHelper.updateTask(updatedTask);
      await RecentActivityHelper.recordActivity(
        Activity(
          type: ActivityType.completed,
          task: updatedTask,
          time: DateTime.now(),
        ),
      );
      showSuccessFlushBar(
        task.isCompleted ? 'Task marked as incomplete' : 'Task completed successfully',
      );
      if (!task.isCompleted) {
        showCelebration.value = true;
        confettiController.play();
        Future.delayed(const Duration(seconds: 1), () {
          showCelebration.value = false;
        });
      }
    }
  }

  Future<void> deleteTask(String id) async {
    final deletedTask = tasks.firstWhere((t) => t.id == id);
    tasks.removeWhere((task) => task.id == id);
    filterTasks();
    await _databaseHelper.deleteTask(id);
    await notificationService.cancelNotification(id.hashCode);
    await RecentActivityHelper.recordActivity(
      Activity(
        type: ActivityType.deleted,
        task: deletedTask,
        time: DateTime.now(),
      ),
    );
    showSuccessFlushBar('Task deleted successfully');
  }

  Future<void> handleTaskEdit(BuildContext context, Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddTaskScreen(task: task,isEditing: true,)
      ),
    );
    if (result != null) {
      if (result == 'delete') {
        await _databaseHelper.deleteTask(task.id);
        await RecentActivityHelper.recordActivity(
          Activity(
            type: ActivityType.deleted,
            task: task,
            time: DateTime.now(),
          ),
        );
        showSuccessFlushBar('Task deleted successfully');
        await loadTasks();
      } else if (result is Map && result['task'] is Task) {
        await loadTasks();
        final updatedTask = result['task'] as Task;
        if (result['action'] == 'updated') {
          showSuccessFlushBar('Task updated successfully');
          await RecentActivityHelper.recordActivity(
            Activity(
              type: ActivityType.edited,
              task: updatedTask,
              time: DateTime.now(),
            ),
          );
        } else if (result['action'] == 'added') {
          showSuccessFlushBar('Task added successfully');
        }
      }
    }
  }

  void showSuccessFlushBar(String message) {
    Flushbar(
      message: message,
      backgroundColor: AppColors.completed,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(10),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    ).show(Get.context!);
  }

  void showErrorFlushBar(String message) {
    Flushbar(
      message: message,
      backgroundColor: AppColors.error,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(10),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      icon: const Icon(Icons.error, color: Colors.white),
    ).show(Get.context!);
  }
}