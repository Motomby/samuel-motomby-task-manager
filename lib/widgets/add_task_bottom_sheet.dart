import 'package:flutter/material.dart';
import '../models/task.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Task) onTaskSaved;
  final Task? existingTask;

  const AddTaskBottomSheet({
    super.key,
    required this.onTaskSaved,
    this.existingTask,
  });

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String? _selectedCategory;
  String? _selectedPriority;
  DateTime? _selectedDueDate;

  final List<String> _categories = [
    'School',
    'Personal',
    'Health',
    'Work',
    'Other'
  ];
  final List<String> _priorities = ['High', 'Medium', 'Low'];

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'School': return const Color(0xFF5B7EDB);
      case 'Personal': return const Color(0xFFA569BD);
      case 'Health': return const Color(0xFFE85D75);
      case 'Work': return const Color(0xFF28A745);
      case 'Other': return const Color(0xFFFFA500);
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return const Color(0xFFDC3545);
      case 'Medium': return const Color(0xFFFFC107);
      case 'Low': return const Color(0xFF28A745);
      default: return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingTask?.description ?? '');

    // Ensure initial values exist in the lists to avoid dropdown errors
    if (widget.existingTask != null) {
      if (_categories.contains(widget.existingTask!.category)) {
        _selectedCategory = widget.existingTask!.category;
      }
      if (_priorities.contains(widget.existingTask!.priority)) {
        _selectedPriority = widget.existingTask!.priority;
      }
      _selectedDueDate = widget.existingTask!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date')),
        );
        return;
      }

      if (widget.existingTask != null) {
        widget.existingTask!.title = _titleController.text.trim();
        widget.existingTask!.description = _descriptionController.text.trim();
        widget.existingTask!.category = _selectedCategory!;
        widget.existingTask!.priority = _selectedPriority!;
        widget.existingTask!.dueDate = _selectedDueDate!;
        widget.onTaskSaved(widget.existingTask!);
      } else {
        final newTask = Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory!,
          priority: _selectedPriority!,
          dueDate: _selectedDueDate!,
        );
        widget.onTaskSaved(newTask);
      }

      Navigator.pop(context); // Close the bottom sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Add padding for the keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existingTask == null ? 'Add New Task' : 'Edit Task',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  IconData icon;
                  switch (category) {
                    case 'School': icon = Icons.school_outlined; break;
                    case 'Personal': icon = Icons.person_outline; break;
                    case 'Health': icon = Icons.favorite_border; break;
                    case 'Work': icon = Icons.work_outline; break;
                    case 'Other': icon = Icons.more_horiz; break;
                    default: icon = Icons.task_outlined;
                  }
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(icon, size: 18, color: _getCategoryColor(category)),
                        ),
                        const SizedBox(width: 10),
                        Text(category, style: TextStyle(color: _getCategoryColor(category), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: _priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(priority, style: TextStyle(color: _getPriorityColor(priority), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a priority';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDueDate == null
                          ? 'No due date chosen'
                          : 'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDueDate == null ? Colors.red : null,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.existingTask == null ? 'Add Task' : 'Save Changes',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
