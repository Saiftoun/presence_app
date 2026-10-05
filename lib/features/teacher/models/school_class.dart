import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolClass {
  final String id;
  final String name;
  final String level;
  final String teacherId;
  final List<String> studentIds;
  final DateTime? createdAt;

  const SchoolClass({
    required this.id,
    required this.name,
    required this.level,
    required this.teacherId,
    this.studentIds = const [],
    this.createdAt,
  });

  factory SchoolClass.fromMap(String id, Map<String, dynamic> map) {
    return SchoolClass(
      id: id,
      name: map['name'] as String? ?? '',
      level: map['level'] as String? ?? '',
      teacherId: map['teacherId'] as String? ?? '',
      studentIds: List<String>.from(map['studentIds'] as List? ?? const []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}