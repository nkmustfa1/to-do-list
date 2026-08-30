import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/repositories/task_repository.dart';
import 'package:todo_list/screens/task_home_page.dart';

class MemoryTaskStore implements TaskStore {
  List<Task> stored = [];

  @override
  Future<TaskLoadResult> load() async => TaskLoadResult(tasks: [...stored]);

  @override
  Future<void> save(List<Task> tasks) async {
    stored = [...tasks];
  }
}

void main() {
  testWidgets('shows empty state and adds a task', (tester) async {
    final store = MemoryTaskStore();

    await tester.pumpWidget(
      MaterialApp(home: TaskHomePage(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No tasks yet'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Ship portfolio app');
    await tester.tap(find.widgetWithText(FilledButton, 'Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Ship portfolio app'), findsOneWidget);
    expect(store.stored.single.title, 'Ship portfolio app');
  });

  testWidgets('empty task displays actionable validation', (tester) async {
    final store = MemoryTaskStore();

    await tester.pumpWidget(
      MaterialApp(home: TaskHomePage(store: store)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add task'));
    await tester.pump();

    expect(find.text('Enter a task title before saving.'), findsOneWidget);
    expect(store.stored, isEmpty);
  });
}
