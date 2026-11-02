import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_message_banner.dart';
import '../../auth/models/app_user.dart';
import '../controllers/admin_class_controller.dart';
import '../models/academic_class.dart';
import 'add_class_view.dart';

class ClassDetailsView extends StatelessWidget {
  final String classId;

  const ClassDetailsView({super.key, required this.classId});

  Future<void> _edit(BuildContext context, AcademicClass academicClass) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddClassView(existing: academicClass)),
    );
  }

  Future<void> _setActive(
    BuildContext context,
    AcademicClass academicClass,
    bool active,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(active ? Icons.unarchive_outlined : Icons.archive_outlined),
        title: Text(active ? 'Restaurer la classe ?' : 'Archiver la classe ?'),
        content: Text(
          active
              ? 'La classe réapparaîtra dans la liste des classes actives.'
              : 'La classe sera retirée des listes actives. Les informations et inscriptions seront conservées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(active ? 'Restaurer' : 'Archiver'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<AdminClassController>().setClassActive(academicClass, active);
    }
  }

  Future<void> _removeStudent(
    BuildContext context,
    AcademicClass academicClass,
    AppUser student,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Retirer cet étudiant ?'),
        content: Text(student.name + ' ne sera plus inscrit dans cette classe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<AdminClassController>().removeStudent(academicClass.id, student.uid);
    }
  }

  Future<void> _addStudents(BuildContext context, AcademicClass academicClass) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _StudentPickerSheet(academicClass: academicClass),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminClassController>();
    final academicClass = controller.classById(classId);
    if (academicClass == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Classe')),
        body: Center(
          child: controller.isLoading
              ? const CircularProgressIndicator()
              : const Text('Cette classe n’est plus disponible.'),
        ),
      );
    }

    final students = controller.studentsOf(academicClass);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(academicClass.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Modifier la classe',
            onPressed: () => _edit(context, academicClass),
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'Options de la classe',
            onSelected: (value) => _setActive(context, academicClass, value == 'restore'),
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: academicClass.isActive ? 'archive' : 'restore',
                child: Text(academicClass.isActive ? 'Archiver' : 'Restaurer'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DetailTag(
                          icon: Icons.groups_outlined,
                          label: academicClass.group,
                        ),
                        _DetailTag(
                          icon: academicClass.isActive ? Icons.check_circle_outline : Icons.archive_outlined,
                          label: academicClass.isActive ? 'Classe active' : 'Classe archivée',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enseignant responsable',
                      style: theme.textTheme.labelLarge?.copyWith(color: AppColors.mutedInk),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      controller.teacherName(academicClass.teacherId),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: theme.textTheme.labelLarge?.copyWith(color: AppColors.mutedInk),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      academicClass.description.isEmpty
                          ? 'Aucune description fournie.'
                          : academicClass.description,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Étudiants inscrits',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: academicClass.isActive
                        ? () => _addStudents(context, academicClass)
                        : null,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                academicClass.studentIds.length.toString() + ' étudiants dans cette classe',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
              ),
              if (controller.error != null) ...[
                const SizedBox(height: 14),
                AppMessageBanner(message: controller.error!, isError: true),
              ],
              const SizedBox(height: 12),
              if (students.isEmpty)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.person_search_outlined, size: 36, color: AppColors.teal),
                      const SizedBox(height: 10),
                      Text('Aucun étudiant inscrit', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        academicClass.isActive
                            ? 'Ajoutez des étudiants pour constituer la liste de la classe.'
                            : 'Les inscriptions sont conservées pendant l’archivage.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk, height: 1.4),
                      ),
                    ],
                  ),
                )
              else
                for (final student in students)
                  _StudentRow(
                    student: student,
                    onRemove: academicClass.isActive
                        ? () => _removeStudent(context, academicClass, student)
                        : null,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.teal),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final AppUser student;
  final VoidCallback? onRemove;

  const _StudentRow({required this.student, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final name = student.name.trim();
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.teal.withAlpha(24),
            foregroundColor: AppColors.tealDark,
            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(student.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedInk)),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: 'Retirer de la classe',
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline_rounded),
              color: Theme.of(context).colorScheme.error,
            ),
        ],
      ),
    );
  }
}

class _StudentPickerSheet extends StatefulWidget {
  final AcademicClass academicClass;

  const _StudentPickerSheet({required this.academicClass});

  @override
  State<_StudentPickerSheet> createState() => _StudentPickerSheetState();
}

class _StudentPickerSheetState extends State<_StudentPickerSheet> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _query = '';
  bool _isAdding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isAdding = true);
    final added = await context.read<AdminClassController>().addStudents(
          widget.academicClass.id,
          _selectedIds.toList(),
        );
    if (!mounted) return;
    setState(() => _isAdding = false);
    if (added) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminClassController>();
    final currentClass = controller.classById(widget.academicClass.id) ?? widget.academicClass;
    final query = _query.trim().toLowerCase();
    final available = controller.availableStudentsFor(currentClass).where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query);
    }).toList();
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ajouter des étudiants',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fermer',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                'Sélectionnez les comptes étudiants actifs à inscrire.',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un étudiant',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              if (controller.error != null) ...[
                const SizedBox(height: 10),
                AppMessageBanner(message: controller.error!, isError: true),
              ],
              const SizedBox(height: 8),
              Expanded(
                child: available.isEmpty
                    ? Center(
                        child: Text(
                          query.isEmpty
                              ? 'Aucun étudiant actif à ajouter.'
                              : 'Aucun étudiant ne correspond à cette recherche.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
                        ),
                      )
                    : ListView.builder(
                        itemCount: available.length,
                        itemBuilder: (context, index) {
                          final student = available[index];
                          return CheckboxListTile(
                            value: _selectedIds.contains(student.uid),
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedIds.add(student.uid);
                                } else {
                                  _selectedIds.remove(student.uid);
                                }
                              });
                            },
                            title: Text(student.name),
                            subtitle: Text(student.email),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.teal,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _selectedIds.isEmpty || _isAdding ? null : _submit,
                child: _isAdding
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Inscrire ' + _selectedIds.length.toString() + ' étudiant(s)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
