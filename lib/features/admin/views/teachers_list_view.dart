import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/teacher_controller.dart';

class TeachersListView extends StatelessWidget {
  const TeachersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TeacherController>();

    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.error != null && ctrl.teachers.isEmpty) {
      return Center(child: Text(ctrl.error!));
    }
    if (ctrl.teachers.isEmpty) {
      return const Center(
        child: Text('Aucun enseignant. Appuyez sur "Ajouter".'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: ctrl.teachers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final t = ctrl.teachers[i];
        return ListTile(
          leading: CircleAvatar(
            child: Text(t.name.isEmpty ? '?' : t.name[0].toUpperCase()),
          ),
          title: Text(t.name),
          subtitle: Text(t.isActive ? t.email : '${t.email} · désactivé'),
          trailing: Switch(
            value: t.isActive,
            onChanged: (v) => ctrl.setActive(t, v),
          ),
        );
      },
    );
  }
}