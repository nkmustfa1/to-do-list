import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/models/task.dart';

void main() {
  test('task round-trips through JSON', () {
    final now = DateTime.utc(2026, 8, 30, 12);
    final task = Task(
      id: '1',
      title: 'Review Flutter basics',
      isCompleted: true,
      createdAt: now,
      updatedAt: now,
    );

    final restored = Task.fromJson(task.toJson());

    expect(restored.id, task.id);
    expect(restored.title, task.title);
    expect(restored.isCompleted, isTrue);
    expect(restored.createdAt, now);
  });

  test('malformed task data is rejected', () {
    expect(
      () => Task.fromJson({'id': '1', 'title': ''}),
      throwsFormatException,
    );
  });
}
