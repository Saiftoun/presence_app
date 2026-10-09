import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presence_app/features/auth/models/app_user.dart';
import 'package:presence_app/features/home/views/role_home_view.dart';

void main() {
  testWidgets('student sees the student landing screen', (tester) async {
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
    expect(find.text('Bonjour Amina\nRôle : student'), findsOneWidget);
  });

  testWidgets('teacher sees the teacher landing screen', (tester) async {
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
    expect(find.text('Bonjour Amine\nRôle : teacher'), findsOneWidget);
  });
}
