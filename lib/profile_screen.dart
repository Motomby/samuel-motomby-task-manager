import 'package:flutter/material.dart';
import 'models/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _programmeController;
  late TextEditingController _bioController;
  late List<TextEditingController> _goalControllers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: globalProfile.name);
    _studentIdController = TextEditingController(text: globalProfile.studentId);
    _programmeController = TextEditingController(text: globalProfile.programme);
    _bioController = TextEditingController(text: globalProfile.bio);
    _goalControllers = globalProfile.goals
        .map((goal) => TextEditingController(text: goal))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _programmeController.dispose();
    _bioController.dispose();
    for (var controller in _goalControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Save changes
      if (_formKey.currentState!.validate()) {
        setState(() {
          globalProfile.name = _nameController.text.trim();
          globalProfile.studentId = _studentIdController.text.trim();
          globalProfile.programme = _programmeController.text.trim();
          globalProfile.bio = _bioController.text.trim();
          globalProfile.goals =
              _goalControllers.map((c) => c.text.trim()).toList();
          _isEditing = false;
        });
        globalProfile.save(); // Persist to storage
      }
    } else {
      // Enter edit mode
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  globalProfile.name.isNotEmpty
                      ? globalProfile.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              _buildEditableTextField(
                controller: _nameController,
                label: 'Name',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _buildEditableTextField(
                controller: _studentIdController,
                label: 'Student ID',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _buildEditableTextField(
                controller: _programmeController,
                label: 'Programme',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildEditableTextField(
                controller: _bioController,
                label: 'Bio',
                maxLines: 4,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Top 3 Goals for the Semester',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_goalControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.star, color: Colors.blue.shade600, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEditableTextField(
                          controller: _goalControllers[index],
                          label: 'Goal ${index + 1}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleEdit,
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  label: Text(
                    _isEditing ? 'Save Profile' : 'Edit Profile',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    int maxLines = 1,
  }) {
    if (_isEditing) {
      return TextFormField(
        controller: controller,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          controller.text,
          style: style,
          textAlign: textAlign,
        ),
      );
    }
  }
}
