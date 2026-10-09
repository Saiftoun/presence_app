import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../auth/models/app_user.dart';
import '../../auth/services/auth_service.dart';
import '../services/teacher_service.dart';

class TeacherController extends ChangeNotifier {
  final TeacherService _service;
  StreamSubscription? _sub;

  List<AppUser> _teachers = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  TeacherController(this._service) {
    _sub = _service.watchTeachers().listen(
      (list) {
        _teachers = list;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Impossible de charger les enseignants.';
        _loading = false;
        notifyListeners();
      },
    );
  }

  List<AppUser> get teachers => _teachers;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;

  Future<bool> createTeacher(String name, String email, String password) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _service.createTeacher(name: name, email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> setActive(AppUser teacher, bool active) async {
    try {
      await _service.setActive(teacher.uid, active);
    } catch (_) {
      _error = 'Modification impossible.';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}