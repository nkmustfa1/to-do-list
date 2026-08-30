import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/controllers/task_controller.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/repositories/task_repository.dart';

class MemoryTaskStore implements TaskStore {
  MemoryTaskStore({List<Task>? initial, this.recovered = false})
      : stored = [...?initial];

  List<Task> stored;
  final bool recovered;
  int saveCount = 0;

  @override
  Future<TaskLoadResult> load() async => TaskLoadResult(
        tasks: [...stored],
        recoveredFromCorruptData: recovered,
      );

  @override
  Future<void> save(List<Task> tasks) async {
    saveCount += 1;
    stored = [...tasks];
  }
}

Task task(String id, String title, {bool completed = false}) {
  final now = DateTime.utc(2026, 8, 30, 12);
  return Task(
    id: id,
    title: title,
    isCompleted: completed,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('empty title returns actionable validation', () async {
    final controller = TaskController(MemoryTaskStore());
    await controller.initialize();

    final error = await controller.addTask('   ');

    expect(error, contains('Enter a task title'));
    expect(controller.tasks, isEmpty);
  });

  test('editing one task preserves other work', () async {
    final store = MemoryTaskStore(initial: [
      task('1', 'First task'),
      task('2', 'Second task'),
    ]);
    final controller = TaskController(store);
    await controller.initialize();

    await controller.editTask('1', 'Updated first task');

    expect(controller.tasks[0].title, 'Updated first task');
    expect(controller.tasks[1].title, 'Second task');
  });

  test('duplicate completion is idempotent', () async {
    final store = MemoryTaskStore(initial: [task('1', 'Complete me')]);
    final controller = TaskController(store);
    await controller.initialize();

    await controller.markCompleted('1');
    final saveCountAfterFirstTap = store.saveCount;
    await controller.markCompleted('1');

    expect(controller.tasks.single.isCompleted, isTrue);
    expect(store.saveCount, saveCountAfterFirstTap);
  });

  test('corrupt local recovery is exposed to the UI', () async {
    final controller = TaskController(MemoryTaskStore(recovered: true));

    await controller.initialize();

    expect(controller.recoveredCorruptData, isTrue);
    expect(controller.isLoading, isFalse);
  });
}
