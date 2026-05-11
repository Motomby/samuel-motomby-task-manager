import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

import 'models/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  globalProfile = await Profile.load();
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
