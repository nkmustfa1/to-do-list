import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../widgets/task_tile.dart';

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key, TaskStore? store}) : store = store;

  final TaskStore? store;

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  late final TaskController _controller;
  final _newTaskController = TextEditingController();
  String? _inputError;

  @override
  void initState() {
    super.initState();
    _controller = TaskController(widget.store ?? SharedPreferencesTaskStore())
      ..addListener(_refresh)
      ..initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    _newTaskController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _addTask() async {
    final validation = _controller.validateTitle(_newTaskController.text);
    if (validation != null) {
      setState(() => _inputError = validation);
      return;
    }

    final error = await _controller.addTask(_newTaskController.text);
    if (!mounted) return;
    if (error != null) {
      _showMessage(error);
      return;
    }
    _newTaskController.clear();
    setState(() => _inputError = null);
  }

  Future<void> _complete(Task task) async {
    final error = await _controller.markCompleted(task.id);
    if (mounted && error != null) _showMessage(error);
  }

  Future<void> _edit(Task task) async {
    final textController = TextEditingController(text: task.title);
    String? dialogError;
    final updatedTitle = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit task'),
          content: TextField(
            controller: textController,
            autofocus: true,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: 'Task title',
              errorText: dialogError,
            ),
            onSubmitted: (value) {
              final error = _controller.validateTitle(value);
              if (error != null) {
                setDialogState(() => dialogError = error);
              } else {
                Navigator.of(context).pop(value.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = textController.text;
                final error = _controller.validateTitle(value);
                if (error != null) {
                  setDialogState(() => dialogError = error);
                } else {
                  Navigator.of(context).pop(value.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    textController.dispose();

    if (updatedTitle == null) return;
    final error = await _controller.editTask(task.id, updatedTitle);
    if (mounted && error != null) _showMessage(error);
  }

  Future<void> _delete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be removed from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await _controller.deleteTask(task.id);
    if (mounted && error != null) _showMessage(error);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        body: Center(
          child: Semantics(
            label: 'Loading saved tasks',
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Plan small. Finish clearly.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tasks stay on this device and are available after relaunch.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newTaskController,
                    maxLength: 80,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'New task',
                      hintText: 'e.g. Review Flutter state management',
                      errorText: _inputError,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      if (_inputError != null) {
                        setState(() => _inputError = null);
                      }
                    },
                    onSubmitted: (_) => _addTask(),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    button: true,
                    label: 'Add task',
                    child: FilledButton.icon(
                      onPressed: _addTask,
                      icon: const Icon(Icons.add_task),
                      label: const Text('Add task'),
                    ),
                  ),
                  if (_controller.recoveredCorruptData) ...[
                    const SizedBox(height: 12),
                    MaterialBanner(
                      content: const Text(
                        'Saved task data was damaged, so the invalid local draft was safely reset.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ],
                  if (_controller.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _controller.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Expanded(
                    child: _controller.tasks.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            itemCount: _controller.tasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final task = _controller.tasks[index];
                              return TaskTile(
                                key: ValueKey(task.id),
                                task: task,
                                onComplete: () => _complete(task),
                                onEdit: () => _edit(task),
                                onDelete: () => _delete(task),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.checklist_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'No tasks yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Add your first task above. Empty lists are a valid state.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
