import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicClass {
  final String id;
  final String name;
  final String group;
  final String description;
  final String teacherId;
  final List<String> studentIds;
  final bool isActive;
  final DateTime? createdAt;

  const AcademicClass({
    required this.id,
    required this.name,
    required this.group,
    required this.description,
    required this.teacherId,
    this.studentIds = const [],
    this.isActive = true,
    this.createdAt,
  });

  factory AcademicClass.fromMap(String id, Map<String, dynamic> map) {
    final rawStudentIds = map['studentIds'];
    final studentIds = rawStudentIds is List
        ? rawStudentIds.whereType<String>().toList(growable: false)
        : const <String>[];

    return AcademicClass(
      id: id,
      name: map['name'] as String? ?? '',
      group: map['group'] as String? ?? '',
      description: map['description'] as String? ?? '',
      teacherId: map['teacherId'] as String? ?? '',
      studentIds: studentIds,
      isActive: map['active'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
