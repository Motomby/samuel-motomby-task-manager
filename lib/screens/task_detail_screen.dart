import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/add_task_bottom_sheet.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  void _openEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddTaskBottomSheet(
          existingTask: widget.task,
          onTaskSaved: (updatedTask) {
            setState(() {
              // The object is updated by reference, so we just trigger a rebuild.
            });
          },
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text(
              'Are you sure you want to delete this task? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      Navigator.pop(context, 'delete'); // Send delete instruction to list screen
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'School': return Icons.school_outlined;
      case 'Personal': return Icons.person_outline;
      case 'Health': return Icons.favorite_border;
      case 'Work': return Icons.work_outline;
      case 'Other': return Icons.more_horiz;
      default: return Icons.task_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bool isOverdue = !widget.task.isCompleted && widget.task.dueDate.isBefore(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _openEditSheet,
            tooltip: 'Edit Task',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
            tooltip: 'Delete Task',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOverdue)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'This task is overdue!',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            Text(
              widget.task.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                decoration: widget.task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  avatar: Icon(_getCategoryIcon(widget.task.category), size: 16),
                  label: Text(widget.task.category),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${widget.task.priority} Priority'),
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  backgroundColor: _getPriorityColor(widget.task.priority),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Due Date: ${widget.task.dueDate.day}/${widget.task.dueDate.month}/${widget.task.dueDate.year}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? Colors.red : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                widget.task.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.task.isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      widget.task.isCompleted
                          ? 'Status: Completed'
                          : 'Status: Pending',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            widget.task.isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.task.isCompleted = !widget.task.isCompleted;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.task.isCompleted ? Colors.grey.shade200 : Colors.blue,
                        foregroundColor: widget.task.isCompleted ? Colors.black87 : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(
                        widget.task.isCompleted ? Icons.undo : Icons.check,
                      ),
                      label: Text(
                        widget.task.isCompleted
                            ? 'Mark as Pending'
                            : 'Mark as Completed',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
