import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { checking, unauthenticated, authenticated, profileError }

class AuthController extends ChangeNotifier {
  static const _profileLoadTimeout = Duration(seconds: 15);

  final AuthService _service;
  StreamSubscription? _authSub;
  StreamSubscription? _profileSub;
  Timer? _profileTimeout;

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
    _authSub = _service.authStateChanges().listen(
      (fbUser) {
        _profileSub?.cancel();
        _profileTimeout?.cancel();

        if (fbUser == null) {
          _user = null;
          _status = AuthStatus.unauthenticated;
          _error = null;
          notifyListeners();
          return;
        }

        _user = null;
        _status = AuthStatus.checking;
        _error = null;
        notifyListeners();

        // Do not leave a signed-in account on the splash screen forever if
        // its Firestore role profile is missing or cannot be read.
        _profileTimeout = Timer(_profileLoadTimeout, () {
          if (_status == AuthStatus.checking && _user == null) {
            _status = AuthStatus.profileError;
            _error = 'Profil introuvable. Demandez à un administrateur de vérifier votre compte.';
            notifyListeners();
          }
        });

        _profileSub = _service.watchProfile(fbUser.uid).listen(
          (profile) async {
            if (profile == null) {
              _user = null;
              _status = AuthStatus.checking;
              notifyListeners();
              return;
            }

            _profileTimeout?.cancel();
            if (!profile.isActive) {
              _user = null;
              _status = AuthStatus.unauthenticated;
              _error = 'Ce compte a été désactivé.';
              notifyListeners();
              await _service.signOut();
              return;
            }

            if (profile.role == UserRole.unknown) {
              _user = null;
              _status = AuthStatus.profileError;
              _error = 'Rôle utilisateur invalide. Contactez un administrateur.';
              notifyListeners();
              return;
            }

            _user = profile;
            _status = AuthStatus.authenticated;
            _error = null;
            notifyListeners();
          },
          onError: (Object _) {
            _profileTimeout?.cancel();
            _user = null;
            _status = AuthStatus.profileError;
            _error = 'Impossible de charger votre profil. Vérifiez la connexion ou contactez un administrateur.';
            notifyListeners();
          },
        );
      },
      onError: (Object _) {
        _profileTimeout?.cancel();
        _user = null;
        _status = AuthStatus.profileError;
        _error = 'Impossible de vérifier votre session. Réessayez.';
        notifyListeners();
      },
    );
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
    _profileTimeout?.cancel();
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
