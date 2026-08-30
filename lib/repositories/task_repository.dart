import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskLoadResult {
  const TaskLoadResult({
    required this.tasks,
    this.recoveredFromCorruptData = false,
  });

  final List<Task> tasks;
  final bool recoveredFromCorruptData;
}

abstract class TaskStore {
  Future<TaskLoadResult> load();
  Future<void> save(List<Task> tasks);
}

class SharedPreferencesTaskStore implements TaskStore {
  static const _storageKey = 'devready_todo_tasks_v1';

  @override
  Future<TaskLoadResult> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const TaskLoadResult(tasks: []);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('Stored task data is not a list.');
      }

      final tasks = decoded
          .map((item) {
            if (item is! Map) {
              throw const FormatException('Stored task item is malformed.');
            }
            return Task.fromJson(Map<String, Object?>.from(item));
          })
          .toList(growable: false);

      return TaskLoadResult(tasks: tasks);
    } catch (error) {
      debugPrint('Recovered from malformed local task data: $error');
      await preferences.remove(_storageKey);
      return const TaskLoadResult(
        tasks: [],
        recoveredFromCorruptData: true,
      );
    }
  }

  @override
  Future<void> save(List<Task> tasks) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = jsonEncode(tasks.map((task) => task.toJson()).toList());
    final success = await preferences.setString(_storageKey, payload);
    if (!success) {
      throw StateError('Could not persist tasks locally.');
    }
  }
}
