import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:presence_app/features/auth/models/app_user.dart';
import 'package:presence_app/features/home/views/role_home_view.dart';

void main() {
  testWidgets('student sees role-specific home and attendance navigation', (tester) async {
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
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Présences'));
    await tester.pumpAndSettle();
    expect(find.text('Mon suivi de présence'), findsOneWidget);
    expect(find.text('Vos présences et votre historique apparaîtront ici après vos premières séances.'), findsOneWidget);
  });

  testWidgets('teacher sees role-specific sessions and attendance navigation', (tester) async {
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
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Séances'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune séance à afficher'), findsOneWidget);
    expect(find.text('Les séances créées par l’administration apparaîtront ici.'), findsOneWidget);

    await tester.tap(find.text('Présences'));
    await tester.pumpAndSettle();
    expect(find.text('Suivi des présences'), findsOneWidget);
    expect(find.text('Les présences des étudiants et la vôtre pendant chaque séance apparaîtront ici.'), findsOneWidget);
  });
}
