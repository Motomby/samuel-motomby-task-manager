class Profile {
  String name;
  String studentId;
  String programme;
  String bio;
  List<String> goals;

  Profile({
    required this.name,
    required this.studentId,
    required this.programme,
    required this.bio,
    required this.goals,
  });
}

// Global instance for simple state management in this scope
final Profile globalProfile = Profile(
  name: 'Ekema',
  studentId: '12345678',
  programme: 'Computer Science',
  bio: 'I am a passionate software engineering student focusing on mobile development. I love building intuitive and aesthetically pleasing user interfaces. In my free time, I enjoy reading tech blogs and contributing to open-source projects.',
  goals: [
    'Master Flutter and Dart',
    'Achieve a GPA of 3.8 or higher',
    'Complete a major side project',
  ],
);
