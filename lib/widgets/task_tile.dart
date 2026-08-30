import 'package:flutter/material.dart';

import '../models/task.dart';

enum TaskAction { edit, delete }

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: task.isCompleted
          ? '${task.title}, completed task'
          : '${task.title}, incomplete task',
      child: Card(
        child: ListTile(
          minVerticalPadding: 12,
          leading: Semantics(
            button: true,
            label: task.isCompleted
                ? 'Task completed'
                : 'Mark ${task.title} as completed',
            child: Checkbox(
              value: task.isCompleted,
              onChanged: task.isCompleted ? null : (_) => onComplete(),
            ),
          ),
          title: Text(
            task.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
          subtitle: Text(task.isCompleted ? 'Completed' : 'Active'),
          trailing: PopupMenuButton<TaskAction>(
            tooltip: 'Task actions',
            onSelected: (action) {
              switch (action) {
                case TaskAction.edit:
                  onEdit();
                case TaskAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: TaskAction.edit,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit'),
                ),
              ),
              PopupMenuItem(
                value: TaskAction.delete,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
