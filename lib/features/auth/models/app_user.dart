import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, teacher, student }

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.student,
      ),
      isActive: map['active'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'active': isActive,
        'createdAt': FieldValue.serverTimestamp(),
      };
}