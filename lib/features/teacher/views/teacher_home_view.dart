import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/class_controller.dart';
import '../models/school_class.dart';
import '../services/class_service.dart';
import 'add_class_view.dart';
import 'class_details_view.dart';

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<AuthController>().user!;

    // Scoped provider: created only for a logged-in teacher
    return ChangeNotifierProvider(
      create: (_) => ClassController(ClassService(), teacher.uid),
      child: Builder(builder: (context) {
        final ctrl = context.watch<ClassController>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mes classes'),
            actions: [
              IconButton(
                tooltip: 'Se déconnecter',
                icon: const Icon(Icons.logout),
                onPressed: () => context.read<AuthController>().signOut(),
              ),
            ],
          ),
          body: _buildBody(context, ctrl),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle classe'),
            onPressed: () => _openForm(context),
          ),
        );
      }),
    );
  }

  Widget _buildBody(BuildContext context, ClassController ctrl) {
    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.error != null && ctrl.classes.isEmpty) {
      return Center(child: Text(ctrl.error!));
    }
    if (ctrl.classes.isEmpty) {
      return const Center(
        child: Text('Aucune classe. Appuyez sur "Nouvelle classe".'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: ctrl.classes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = ctrl.classes[i];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.groups_outlined)),
          title: Text(c.name),
          subtitle: Text('${c.level} · ${c.studentIds.length} étudiant(s)'),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _openForm(context, existing: c);
              if (value == 'delete') _confirmDelete(context, c);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Modifier')),
              PopupMenuItem(value: 'delete', child: Text('Supprimer')),
            ],
          ),
          onTap: () {
            final controller = context.read<ClassController>();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: controller,
                child: ClassDetailsView(classId: c.id),
              ),
            ));
          },
        );
      },
    );
  }

  void _openForm(BuildContext context, {SchoolClass? existing}) {
    final controller = context.read<ClassController>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: AddClassView(existing: existing),
      ),
    ));
  }

  Future<void> _confirmDelete(BuildContext context, SchoolClass c) async {
    final controller = context.read<ClassController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la classe ?'),
        content: Text('"${c.name}" sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) await controller.deleteClass(c.id);
  }
}