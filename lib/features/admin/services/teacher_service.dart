import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../auth/models/app_user.dart';
import '../../auth/services/auth_service.dart';

class TeacherService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Stream<List<AppUser>> watchTeachers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppUser.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
  }

  /// Creates a teacher account on the trusted server. The callable verifies
  /// the current user's admin role before creating Firebase Auth and Firestore
  /// records, so the admin's session is never replaced by the new account.
  Future<void> createTeacher({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _functions.httpsCallable('createManagedUser').call({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': 'teacher',
      });
    } on FirebaseFunctionsException catch (e) {
      throw AuthException(_messageFor(e.code));
    } catch (_) {
      throw const AuthException('Création impossible. Réessayez.');
    }
  }

  Future<void> setActive(String uid, bool active) {
    return _db.collection('users').doc(uid).update({'active': active});
  }

  String _messageFor(String code) {
    switch (code) {
      case 'already-exists':
        return 'Cet email est déjà utilisé.';
      case 'invalid-argument':
        return 'Vérifiez le nom, l'email et le mot de passe.';
      case 'unauthenticated':
        return 'Reconnectez-vous pour continuer.';
      case 'permission-denied':
        return 'Cette action est réservée à un administrateur.';
      case 'unavailable':
        return 'Service indisponible. Réessayez plus tard.';
      default:
        return 'Création impossible. Réessayez.';
    }
  }
}
