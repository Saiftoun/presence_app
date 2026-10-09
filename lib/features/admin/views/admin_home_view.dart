import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/teacher_controller.dart';
import '../services/teacher_service.dart';
import 'add_teacher_view.dart';
import 'teachers_list_view.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Scoped provider: only created when the admin is logged in
    return ChangeNotifierProvider(
      create: (_) => TeacherController(TeacherService()),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Enseignants'),
            actions: [
              IconButton(
                tooltip: 'Se déconnecter',
                icon: const Icon(Icons.logout),
                onPressed: () => context.read<AuthController>().signOut(),
              ),
            ],
          ),
          body: const TeachersListView(),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Ajouter'),
            onPressed: () {
              final ctrl = context.read<TeacherController>();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: ctrl,
                  child: const AddTeacherView(),
                ),
              ));
            },
          ),
        );
      }),
    );
  }
}