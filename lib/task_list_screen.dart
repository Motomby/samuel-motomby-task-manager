import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'models/task.dart';
import 'widgets/task_card.dart';
import 'screens/task_detail_screen.dart';
import 'widgets/add_task_bottom_sheet.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [
    Task(
      title: 'Complete Flutter Assignment',
      description: 'Finish the Task Manager app assignment with all the required features including models, lists, and navigation.',
      category: 'School',
      priority: 'High',
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
    Task(
      title: 'Study for Midterms',
      description: 'Review notes and practice problems for the upcoming midterms.',
      category: 'School',
      priority: 'High',
      dueDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Task(
      title: 'Go to the Gym',
      description: 'Leg day routine with 30 mins of cardio.',
      category: 'Health',
      priority: 'Medium',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
  ];

  String _currentFilter = 'All';

  List<Task> get _filteredTasks {
    if (_currentFilter == 'Pending') {
      return _tasks.where((t) => !t.isCompleted).toList();
    } else if (_currentFilter == 'Completed') {
      return _tasks.where((t) => t.isCompleted).toList();
    }
    return _tasks;
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'All', label: Text('All')),
                  ButtonSegment(value: 'Pending', label: Text('Pending')),
                  ButtonSegment(value: 'Completed', label: Text('Completed')),
                ],
                selected: {_currentFilter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _currentFilter = newSelection.first;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: _filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _tasks.isEmpty ? 'No tasks yet!' : 'No tasks found.',
                          style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tasks.isEmpty
                              ? 'Tap the + button to add a new task.'
                              : 'Change the filter to see other tasks.',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return Dismissible(
                        key: Key('${task.title}_${task.dueDate.millisecondsSinceEpoch}_${task.hashCode}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteTask(task);
                        },
                        child: TaskCard(
                          task: task,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(task: task),
                              ),
                            ).then((result) {
                              if (result == 'delete') {
                                _deleteTask(task);
                              } else {
                                setState(() {});
                              }
                            });
                          },
                          onToggleComplete: () => _toggleTaskCompletion(task),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return AddTaskBottomSheet(
                onTaskSaved: (newTask) {
                  setState(() {
                    _tasks.add(newTask);
                  });
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
