import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../auth/models/app_user.dart';
import '../models/academic_class.dart';
import '../services/admin_class_service.dart';

class AdminClassController extends ChangeNotifier {
  final AdminClassService _service;
  StreamSubscription<List<AcademicClass>>? _classesSub;
  StreamSubscription<List<AppUser>>? _teachersSub;
  StreamSubscription<List<AppUser>>? _studentsSub;

  List<AcademicClass> _classes = [];
  List<AppUser> _teachers = [];
  List<AppUser> _students = [];
  bool _classesLoading = true;
  bool _teachersLoading = true;
  bool _studentsLoading = true;
  bool _isSaving = false;
  String? _error;

  AdminClassController(this._service) {
    _classesSub = _service.watchClasses().listen(
      (classes) {
        _classes = classes;
        _classesLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _classesLoading = false;
        _error = 'Impossible de charger les classes.';
        notifyListeners();
      },
    );
    _teachersSub = _service.watchTeachers().listen(
      (teachers) {
        _teachers = teachers;
        _teachersLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _teachersLoading = false;
        _error = 'Impossible de charger les enseignants.';
        notifyListeners();
      },
    );
    _studentsSub = _service.watchStudents().listen(
      (students) {
        _students = students;
        _studentsLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _studentsLoading = false;
        _error = 'Impossible de charger les étudiants.';
        notifyListeners();
      },
    );
  }

  List<AcademicClass> get classes => _classes;
  List<AppUser> get teachers => _teachers;
  List<AppUser> get activeTeachers => _teachers.where((user) => user.isActive).toList();
  List<AppUser> get activeStudents => _students.where((user) => user.isActive).toList();
  bool get isLoading => _classesLoading || _teachersLoading || _studentsLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  AcademicClass? classById(String id) {
    for (final academicClass in _classes) {
      if (academicClass.id == id) return academicClass;
    }
    return null;
  }

  String teacherName(String teacherId) {
    for (final teacher in _teachers) {
      if (teacher.uid == teacherId) return teacher.name;
    }
    return 'Enseignant indisponible';
  }

  List<AppUser> studentsOf(AcademicClass academicClass) {
    return _students
        .where((student) => academicClass.studentIds.contains(student.uid))
        .toList();
  }

  List<AppUser> availableStudentsFor(AcademicClass academicClass) {
    return activeStudents
        .where((student) => !academicClass.studentIds.contains(student.uid))
        .toList();
  }

  Future<bool> saveClass({
    String? classId,
    required String name,
    required String group,
    required String description,
    required String teacherId,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      if (classId == null) {
        await _service.createClass(
          name: name,
          group: group,
          description: description,
          teacherId: teacherId,
        );
      } else {
        await _service.updateClass(
          classId: classId,
          name: name,
          group: group,
          description: description,
          teacherId: teacherId,
        );
      }
      return true;
    } catch (_) {
      _error = 'Enregistrement impossible. Vérifiez les informations et réessayez.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> setClassActive(AcademicClass academicClass, bool active) async {
    try {
      await _service.setClassActive(academicClass.id, active);
    } catch (_) {
      _error = 'Modification impossible. Réessayez.';
      notifyListeners();
    }
  }

  Future<bool> addStudents(String classId, List<String> studentIds) async {
    try {
      await _service.addStudents(classId, studentIds);
      return true;
    } catch (_) {
      _error = 'Impossible d’ajouter les étudiants à cette classe.';
      notifyListeners();
      return false;
    }
  }

  Future<void> removeStudent(String classId, String studentId) async {
    try {
      await _service.removeStudent(classId, studentId);
    } catch (_) {
      _error = 'Impossible de retirer cet étudiant de la classe.';
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
    _teachersSub?.cancel();
    _studentsSub?.cancel();
    super.dispose();
  }
}
