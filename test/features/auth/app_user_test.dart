import 'package:flutter_test/flutter_test.dart';
import 'package:presence_app/features/auth/models/app_user.dart';

void main() {
  group('UserRole', () {
    test('parses every supported role', () {
      expect(UserRole.fromValue('admin'), UserRole.admin);
      expect(UserRole.fromValue('teacher'), UserRole.teacher);
      expect(UserRole.fromValue('student'), UserRole.student);
    });

    test('unknown role stays unknown instead of becoming a student', () {
      expect(UserRole.fromValue('unexpected'), UserRole.unknown);
      expect(UserRole.fromValue(null), UserRole.unknown);
      expect(UserRole.unknown.dashboardTitle, 'Compte non configuré');
    });

    test('maps each role to its own dashboard label', () {
      expect(UserRole.admin.dashboardTitle, 'Espace Administrateur');
      expect(UserRole.teacher.dashboardTitle, 'Espace Enseignant');
      expect(UserRole.student.dashboardTitle, 'Espace Étudiant');
    });

    test('reads the active state from a user profile', () {
      final user = AppUser.fromMap('teacher-1', {
        'name': 'Amine',
        'email': 'amine@example.test',
        'role': 'teacher',
        'active': false,
      });

      expect(user.role, UserRole.teacher);
      expect(user.isActive, isFalse);
    });
  });
}
