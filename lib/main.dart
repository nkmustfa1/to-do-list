import 'package:flutter/material.dart';

import 'screens/task_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF155EEF),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DevReady To-Do',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
        ),
      ),
      home: const TaskHomePage(),
    );
  }
}
