import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../auth/models/app_user.dart';
import '../models/school_class.dart';
import '../services/class_service.dart';

class ClassController extends ChangeNotifier {
  final ClassService _service;
  final String teacherId;
  StreamSubscription? _classesSub;
  StreamSubscription? _studentsSub;

  List<SchoolClass> _classes = [];
  List<AppUser> _students = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  ClassController(this._service, this.teacherId) {
    _classesSub = _service.watchMyClasses(teacherId).listen(
      (list) {
        _classes = list;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Impossible de charger les classes.';
        _loading = false;
        notifyListeners();
      },
    );

    _studentsSub = _service.watchAllStudents().listen(
      (list) {
        _students = list;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Impossible de charger les étudiants.';
        notifyListeners();
      },
    );
  }

  List<SchoolClass> get classes => _classes;
  List<AppUser> get allStudents => _students;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;

  SchoolClass? classById(String id) {
    for (final c in _classes) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Students that belong to the given class.
  List<AppUser> studentsOf(SchoolClass c) =>
      _students.where((s) => c.studentIds.contains(s.uid)).toList();

  /// Students that are NOT yet in the given class.
  List<AppUser> availableStudentsFor(SchoolClass c) =>
      _students.where((s) => !c.studentIds.contains(s.uid)).toList();

  Future<bool> saveClass({
    String? classId,
    required String name,
    required String level,
  }) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      if (classId == null) {
        await _service.createClass(
          name: name,
          level: level,
          teacherId: teacherId,
        );
      } else {
        await _service.updateClass(classId, name, level);
      }
      return true;
    } catch (_) {
      _error = 'Enregistrement impossible. Réessayez.';
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      await _service.deleteClass(classId);
    } catch (_) {
      _error = 'Suppression impossible.';
      notifyListeners();
    }
  }

  Future<void> addStudent(String classId, String studentId) async {
    try {
      await _service.addStudent(classId, studentId);
    } catch (_) {
      _error = 'Ajout impossible.';
      notifyListeners();
    }
  }

  Future<void> removeStudent(String classId, String studentId) async {
    try {
      await _service.removeStudent(classId, studentId);
    } catch (_) {
      _error = 'Retrait impossible.';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _classesSub?.cancel();
    _studentsSub?.cancel();
    super.dispose();
  }
}