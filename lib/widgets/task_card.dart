import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
  });

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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bool isOverdue = !task.isCompleted && task.dueDate.isBefore(today);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isOverdue ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue ? Colors.red.withOpacity(0.6) : Colors.grey.shade300,
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isOverdue
              ? LinearGradient(
                  colors: [Colors.red.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : task.isCompleted
                  ? LinearGradient(
                      colors: [Colors.grey.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
          color: isOverdue || task.isCompleted ? null : Colors.white,
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Checkbox(
              value: task.isCompleted,
              activeColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (value) => onToggleComplete(),
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isOverdue ? Colors.red.shade900 : 
                     task.isCompleted ? Colors.grey.shade600 : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getCategoryIcon(task.category), 
                      size: 14, 
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    task.category, 
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getPriorityColor(task.priority).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      task.priority,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _getPriorityColor(task.priority),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined, 
                    size: 12, 
                    color: isOverdue ? Colors.red.shade600 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                    style: TextStyle(
                      fontSize: 11, 
                      color: isOverdue ? Colors.red.shade600 : Colors.grey.shade600,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: TextStyle(
                          fontSize: 9, 
                          color: Colors.red.shade800, 
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right, 
            color: Colors.grey.shade400,
            size: 20,
          ),
        ),
      ),
    );
  }
}
