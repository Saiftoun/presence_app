import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presence_app/features/auth/models/app_user.dart';
import 'package:presence_app/features/home/views/role_home_view.dart';

void main() {
  testWidgets('student sees a student-specific landing screen', (tester) async {
    final user = AppUser(
      uid: 'student-1',
      name: 'Amina',
      email: 'amina@example.test',
      role: UserRole.student,
    );

    await tester.pumpWidget(MaterialApp(
      home: RoleHomeView(title: user.role.dashboardTitle, user: user),
    ));

    expect(find.text('Espace Étudiant'), findsOneWidget);
    expect(find.text('Bonjour, Amina'), findsOneWidget);
    expect(find.text('Vos séances et votre historique de présence seront centralisés ici.'), findsOneWidget);
    expect(find.text('amina@example.test'), findsOneWidget);
  });

  testWidgets('teacher sees a teacher-specific landing screen', (tester) async {
    final user = AppUser(
      uid: 'teacher-1',
      name: 'Amine',
      email: 'amine@example.test',
      role: UserRole.teacher,
    );

    await tester.pumpWidget(MaterialApp(
      home: RoleHomeView(title: user.role.dashboardTitle, user: user),
    ));

    expect(find.text('Espace Enseignant'), findsOneWidget);
    expect(find.text('Bonjour, Amine'), findsOneWidget);
    expect(find.text('La gestion des séances et le suivi des présences seront centralisés ici.'), findsOneWidget);
    expect(find.text('amine@example.test'), findsOneWidget);
  });
}
