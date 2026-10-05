import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
            .map((d) => AppUser.fromMap(d.id, d.data()))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
  }

  Future<void> createTeacher({
    required String name,
    required String email,
    required String password,
  }) async {
    // Open the second connection (reuse it if it already exists)
    FirebaseApp secondary;
    try {
      secondary = Firebase.app('secondary');
    } catch (_) {
      secondary = await Firebase.initializeApp(
        name: 'secondary',
        options: Firebase.app().options,
      );
    }

    // Create the Auth account on the second connection only
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondary);
    UserCredential? cred;
    try {
      cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Profile written with the DEFAULT app, so the request comes from the admin
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'teacher',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    } catch (_) {
      await cred?.user?.delete();
      throw const AuthException('Création impossible. Réessayez.');
    } finally {
      await secondaryAuth.signOut();
    }
  }

  Future<void> setActive(String uid, bool active) {
    return _db.collection('users').doc(uid).update({'active': active});
  }

  String _messageFor(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'network-request-failed':
        return 'Problème de connexion internet.';
      default:
        return 'Une erreur est survenue. Réessayez.';
    }
  }
}