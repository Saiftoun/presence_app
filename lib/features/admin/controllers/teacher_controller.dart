import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../auth/models/app_user.dart';
import '../../auth/services/auth_service.dart';
import '../services/teacher_service.dart';

class TeacherController extends ChangeNotifier {
  final TeacherService _service;
  StreamSubscription? _teachersSub;

  List<AppUser> _teachers = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  TeacherController(this._service) {
    _teachersSub = _service.watchTeachers().listen(
      (list) {
        _teachers = list;
        _updateLoadingState();
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

  Future<bool> createTeacher({
    required String name,
    required String email,
    required String password,
  }) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _service.createTeacher(
        name: name,
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } on FirebaseException catch (e) {
      _error = e.code == 'permission-denied'
          ? 'Cette action est réservée à un administrateur.'
          : 'Promotion impossible. Réessayez.';
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

  void showError(String message) {
    _error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _teachersSub?.cancel();
    super.dispose();
  }

  void _updateLoadingState() {
    _loading = false;
  }
}