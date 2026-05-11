import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  final List<Task> _tasks = [];

  String _currentFilter = 'All';
  String _currentSort = 'None';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('user_tasks', encodedData);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('user_tasks');
    if (data != null) {
      final List<dynamic> decodedData = jsonDecode(data);
      setState(() {
        _tasks.clear();
        _tasks.addAll(decodedData.map((t) => Task.fromJson(t)).toList());
      });
    }
  }

  List<Task> get _filteredTasks {
    List<Task> tasksToDisplay = List.from(_tasks);

    if (_currentFilter == 'Pending') {
      tasksToDisplay = tasksToDisplay.where((t) => !t.isCompleted).toList();
    } else if (_currentFilter == 'Completed') {
      tasksToDisplay = tasksToDisplay.where((t) => t.isCompleted).toList();
    }

    if (_searchController.text.isNotEmpty) {
      tasksToDisplay = tasksToDisplay.where((t) =>
          t.title.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }

    if (_currentSort == 'DueDate') {
      tasksToDisplay.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_currentSort == 'Priority') {
      final priorityMap = {'High': 0, 'Medium': 1, 'Low': 2};
      tasksToDisplay.sort((a, b) =>
          priorityMap[a.priority]!.compareTo(priorityMap[b.priority]!));
    }

    return tasksToDisplay;
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
    _saveTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    _saveTasks();
  }

  void _clearAllTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text('Are you sure you want to delete all tasks? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tasks.clear();
              });
              _saveTasks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All tasks cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalTasks = _tasks.length;
    int completedTasks = _tasks.where((t) => t.isCompleted).length;
    int pendingTasks = totalTasks - completedTasks;
    double completionPercentage = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('Task Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All',
            onPressed: _tasks.isEmpty ? null : _clearAllTasks,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort tasks',
            onSelected: (value) {
              setState(() {
                _currentSort = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'None', child: Text('Default Order')),
              const PopupMenuItem(value: 'DueDate', child: Text('Due Date (Earliest First)')),
              const PopupMenuItem(value: 'Priority', child: Text('Priority (High to Low)')),
            ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total', totalTasks),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        _buildStatItem('Completed', completedTasks),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        _buildStatItem('Pending', pendingTasks),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completionPercentage,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(completionPercentage * 100).toInt()}% Completed',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
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
                                _saveTasks();
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
                  _saveTasks();
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
