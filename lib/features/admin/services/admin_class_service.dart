import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/app_user.dart';
import '../models/academic_class.dart';

class AdminClassService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<AcademicClass>> watchClasses() {
    return _db.collection('classes').snapshots().map((snapshot) {
      final classes = snapshot.docs
          .map((doc) => AcademicClass.fromMap(doc.id, doc.data()))
          .toList();
      classes.sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return classes;
    });
  }

  Stream<List<AppUser>> watchTeachers() => _watchUsers('teacher');

  Stream<List<AppUser>> watchStudents() => _watchUsers('student');

  Stream<List<AppUser>> _watchUsers(String role) {
    return _db
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) => AppUser.fromMap(doc.id, doc.data()))
          .toList();
      users.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return users;
    });
  }

  Future<void> createClass({
    required String name,
    required String group,
    required String description,
    required String teacherId,
  }) async {
    await _db.collection('classes').add({
      'name': name.trim(),
      'group': group.trim(),
      'description': description.trim(),
      'teacherId': teacherId,
      'studentIds': <String>[],
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateClass({
    required String classId,
    required String name,
    required String group,
    required String description,
    required String teacherId,
  }) {
    return _db.collection('classes').doc(classId).update({
      'name': name.trim(),
      'group': group.trim(),
      'description': description.trim(),
      'teacherId': teacherId,
    });
  }

  Future<void> setClassActive(String classId, bool active) {
    return _db.collection('classes').doc(classId).update({'active': active});
  }

  Future<void> addStudents(String classId, List<String> studentIds) async {
    if (studentIds.isEmpty) return;
    await _db.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayUnion(studentIds),
    });
  }

  Future<void> removeStudent(String classId, String studentId) {
    return _db.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayRemove([studentId]),
    });
  }
}
