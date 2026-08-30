import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._store);

  final TaskStore _store;
  List<Task> _tasks = const [];
  bool _isLoading = true;
  bool _recoveredCorruptData = false;
  String? _errorMessage;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  bool get recoveredCorruptData => _recoveredCorruptData;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _store.load();
      _tasks = result.tasks;
      _recoveredCorruptData = result.recoveredFromCorruptData;
    } catch (_) {
      _errorMessage = 'Could not load your saved tasks. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? validateTitle(String value) {
    final title = value.trim();
    if (title.isEmpty) return 'Enter a task title before saving.';
    if (title.length < 2) return 'Task title must contain at least 2 characters.';
    if (title.length > 80) return 'Task title must be 80 characters or fewer.';
    return null;
  }

  Future<String?> addTask(String rawTitle) async {
    final validation = validateTitle(rawTitle);
    if (validation != null) return validation;

    final now = DateTime.now();
    final task = Task(
      id: now.microsecondsSinceEpoch.toString(),
      title: rawTitle.trim(),
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
    return _persist([..._tasks, task]);
  }

  Future<String?> editTask(String taskId, String rawTitle) async {
    final validation = validateTitle(rawTitle);
    if (validation != null) return validation;
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return 'This task is no longer available.';

    final next = [..._tasks];
    next[index] = next[index].copyWith(
      title: rawTitle.trim(),
      updatedAt: DateTime.now(),
    );
    return _persist(next);
  }

  Future<String?> markCompleted(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return 'This task is no longer available.';
    if (_tasks[index].isCompleted) return null;

    final next = [..._tasks];
    next[index] = next[index].copyWith(
      isCompleted: true,
      updatedAt: DateTime.now(),
    );
    return _persist(next);
  }

  Future<String?> deleteTask(String taskId) async {
    if (!_tasks.any((task) => task.id == taskId)) {
      return 'This task is no longer available.';
    }
    return _persist(_tasks.where((task) => task.id != taskId).toList());
  }

  Future<String?> _persist(List<Task> next) async {
    _errorMessage = null;
    try {
      await _store.save(next);
      _tasks = next;
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = 'Could not save this change locally. Please try again.';
      notifyListeners();
      return _errorMessage;
    }
  }
}
