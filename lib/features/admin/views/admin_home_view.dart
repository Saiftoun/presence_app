import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/teacher_controller.dart';
import '../services/teacher_service.dart';
import 'add_teacher_view.dart';
import 'teachers_list_view.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeacherController(TeacherService()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.fact_check_rounded, size: 19, color: Colors.white),
                ),
                const SizedBox(width: 11),
                const Text('Présence'),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Se déconnecter',
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => context.read<AuthController>().signOut(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: const TeachersListView(),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Ajouter'),
            onPressed: () {
              final controller = context.read<TeacherController>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: controller,
                    child: const AddTeacherView(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
