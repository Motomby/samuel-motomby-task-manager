import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() => {
        'name': name,
        'studentId': studentId,
        'programme': programme,
        'bio': bio,
        'goals': goals,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        name: json['name'] ?? '',
        studentId: json['studentId'] ?? '',
        programme: json['programme'] ?? '',
        bio: json['bio'] ?? '',
        goals: List<String>.from(json['goals'] ?? []),
      );

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(toJson()));
  }

  static Future<Profile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_profile');
    if (data != null) {
      return Profile.fromJson(jsonDecode(data));
    }
    return Profile(
      name: '',
      studentId: '',
      programme: '',
      bio: '',
      goals: ['', '', ''],
    );
  }
}

// Global instance for simple state management in this scope
Profile globalProfile = Profile(
  name: '',
  studentId: '',
  programme: '',
  bio: '',
  goals: ['', '', ''],
);
