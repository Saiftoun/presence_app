import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/class_controller.dart';

class ClassDetailsView extends StatelessWidget {
  final String classId;
  const ClassDetailsView({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ClassController>();
    final c = ctrl.classById(classId);

    // The class was deleted or is not loaded yet
    if (c == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Classe introuvable.')),
      );
    }

    final students = ctrl.studentsOf(c);

    return Scaffold(
      appBar: AppBar(title: Text(c.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '${c.level} · ${students.length} étudiant(s)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text('Aucun étudiant. Appuyez sur "Ajouter".'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = students[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                              s.name.isEmpty ? '?' : s.name[0].toUpperCase()),
                        ),
                        title: Text(s.name),
                        subtitle: Text(s.email),
                        trailing: IconButton(
                          tooltip: 'Retirer de la classe',
                          icon: const Icon(Icons.person_remove_outlined),
                          onPressed: () => ctrl.removeStudent(c.id, s.uid),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ajouter'),
        onPressed: () {
          final controller = context.read<ClassController>();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: _AddStudentsSheet(classId: classId),
            ),
          );
        },
      ),
    );
  }
}

class _AddStudentsSheet extends StatelessWidget {
  final String classId;
  const _AddStudentsSheet({required this.classId});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ClassController>();
    final c = ctrl.classById(classId);
    if (c == null) return const SizedBox.shrink();

    final available = ctrl.availableStudentsFor(c);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Ajouter des étudiants',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            if (available.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('Aucun étudiant disponible.'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: available.length,
                  itemBuilder: (context, i) {
                    final s = available[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                            s.name.isEmpty ? '?' : s.name[0].toUpperCase()),
                      ),
                      title: Text(s.name),
                      subtitle: Text(s.email),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () => ctrl.addStudent(c.id, s.uid),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}