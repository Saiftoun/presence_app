import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';
import '../../auth/models/app_user.dart';
import '../../auth/services/auth_service.dart';

class TeacherService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Future<void> createTeacher({
    required String name,
    required String email,
    required String password,
  }) async {
    final appName = 'teacher-creation-${DateTime.now().microsecondsSinceEpoch}';
    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;
    User? createdUser;
    var profileCreated = false;
    final normalizedEmail = email.trim().toLowerCase();
    try {
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
      secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      createdUser = credential.user;
      if (createdUser == null) {
        throw const AuthException('Compte enseignant impossible à créer.');
      }

      await _db.collection('users').doc(createdUser.uid).set({
        'name': name.trim(),
        'email': normalizedEmail,
        'role': 'teacher',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      profileCreated = true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthException(
          'Cette action est réservée à un administrateur.',
        );
      }
      throw const AuthException('Création impossible. Réessayez.');
    } finally {
      if (!profileCreated && createdUser != null && secondaryAuth != null) {
        try {
          await createdUser.delete();
        } catch (_) {
          // Keep the original failure; the account can be reconciled manually.
        }
      }
      await secondaryAuth?.signOut();
      await secondaryApp?.delete();
    }
  }

  Future<void> setActive(String uid, bool active) {
    return _db.collection('users').doc(uid).update({'active': active});
  }

  String _messageFor(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet e-mail est déjà utilisé.';
      case 'invalid-email':
        return 'Adresse e-mail invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'network-request-failed':
        return 'Problème de connexion internet.';
      default:
        return 'Création impossible. Réessayez.';
    }
  }
}
