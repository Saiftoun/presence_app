import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/app_user.dart';
import '../models/school_class.dart';

class ClassService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Live list of the classes owned by this teacher.
  Stream<List<SchoolClass>> watchMyClasses(String teacherId) {
    return _db
        .collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SchoolClass.fromMap(d.id, d.data()))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
  }

  /// Live version of one class (used by the details screen).
  Stream<SchoolClass?> watchClass(String classId) {
    return _db.collection('classes').doc(classId).snapshots().map(
          (doc) => doc.exists ? SchoolClass.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Future<void> createClass({
    required String name,
    required String level,
    required String teacherId,
  }) {
    return _db.collection('classes').add({
      'name': name,
      'level': level,
      'teacherId': teacherId,
      'studentIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateClass(String classId, String name, String level) {
    return _db.collection('classes').doc(classId).update({
      'name': name,
      'level': level,
    });
  }

  Future<void> deleteClass(String classId) {
    return _db.collection('classes').doc(classId).delete();
  }

  /// All student profiles (the rules let teachers read students only).
  Stream<List<AppUser>> watchAllStudents() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppUser.fromMap(d.id, d.data()))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
  }

  Future<void> addStudent(String classId, String studentId) {
    return _db.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayUnion([studentId]),
    });
  }

  Future<void> removeStudent(String classId, String studentId) {
    return _db.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayRemove([studentId]),
    });
  }
}