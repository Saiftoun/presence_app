import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

class AuthController extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription? _authSub;
  StreamSubscription? _profileSub;

  AuthStatus _status = AuthStatus.checking;
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AuthController(this._service) {
    _listen();
  }

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _listen() {
    _authSub = _service.authStateChanges().listen((fbUser) {
      _profileSub?.cancel();

      if (fbUser == null) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      // Listen to Firestore profile changes
      _profileSub = _service.watchProfile(fbUser.uid).listen((profile) async {
        if (profile != null && !profile.isActive) {
          // Account is disabled by admin: force sign out
          _user = null;
          _status = AuthStatus.unauthenticated;
          _error = 'Ce compte a été désactivé.';
          notifyListeners();
          await _service.signOut();
          return;
        }

        _user = profile;
        _status = profile == null
            ? AuthStatus.checking
            : AuthStatus.authenticated;
        notifyListeners();
      });
    });
  }

  Future<bool> signIn(String email, String password) =>
      _run(() => _service.signIn(email, password));

  Future<bool> registerStudent(String name, String email, String password) =>
      _run(() => _service.registerStudent(
            name: name,
            email: email,
            password: password,
          ));

  Future<bool> resetPassword(String email) =>
      _run(() => _service.sendPasswordReset(email));

  Future<void> signOut() => _service.signOut();

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Une erreur est survenue. Réessayez.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}