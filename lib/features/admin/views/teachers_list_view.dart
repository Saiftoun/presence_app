import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/app_user.dart';
import '../controllers/teacher_controller.dart';

class TeachersListView extends StatefulWidget {
  const TeachersListView({super.key});

  @override
  State<TeachersListView> createState() => _TeachersListViewState();
}

class _TeachersListViewState extends State<TeachersListView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _changeActive(AppUser teacher, bool active) async {
    if (!active) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.person_off_outlined),
          title: const Text('Désactiver ce compte ?'),
          content: const Text('L’enseignant ne pourra plus accéder à son espace.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Désactiver'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await context.read<TeacherController>().setActive(teacher, active);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeacherController>();
    final teachers = controller.teachers;
    final activeCount = teachers.where((teacher) => teacher.isActive).length;
    final query = _query.trim().toLowerCase();
    final filteredTeachers = teachers.where((teacher) {
      return teacher.name.toLowerCase().contains(query) ||
          teacher.email.toLowerCase().contains(query);
    }).toList();
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
          children: [
            Text(
              'Gestion des enseignants',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Ajoutez un étudiant existant à votre équipe et gérez les comptes enseignants.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedInk,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            _TeacherSummary(
              total: teachers.length,
              active: activeCount,
              inactive: teachers.length - activeCount,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou e-mail',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer la recherche',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            if (controller.error != null) ...[
              const SizedBox(height: 16),
              _InlineNotice(message: controller.error!),
            ],
            const SizedBox(height: 18),
            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (teachers.isEmpty)
              const _EmptyTeachersState(
                title: 'Aucun enseignant pour le moment',
                message: 'Ajoutez le premier compte enseignant avec le bouton ci-dessous.',
              )
            else if (filteredTeachers.isEmpty)
              const _EmptyTeachersState(
                title: 'Aucun résultat',
                message: 'Essayez un autre nom ou une autre adresse e-mail.',
              )
            else ...[
              Text(
                'ÉQUIPE ENSEIGNANTE',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedInk,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              for (final teacher in filteredTeachers)
                _TeacherCard(
                  teacher: teacher,
                  onActiveChanged: (active) => _changeActive(teacher, active),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeacherSummary extends StatelessWidget {
  final int total;
  final int active;
  final int inactive;

  const _TeacherSummary({
    required this.total,
    required this.active,
    required this.inactive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _SummaryMetric(value: total.toString(), label: 'Enseignants')),
          Container(width: 1, height: 42, color: const Color(0x44FFFFFF)),
          Expanded(child: _SummaryMetric(value: active.toString(), label: 'Actifs')),
          Container(width: 1, height: 42, color: const Color(0x44FFFFFF)),
          Expanded(child: _SummaryMetric(value: inactive.toString(), label: 'Inactifs')),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xD9FFFFFF),
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final AppUser teacher;
  final ValueChanged<bool> onActiveChanged;

  const _TeacherCard({required this.teacher, required this.onActiveChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = teacher.name.trim();
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    final statusColor = teacher.isActive ? AppColors.teal : AppColors.mutedInk;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.teal.withAlpha(24),
            foregroundColor: AppColors.tealDark,
            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  teacher.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: teacher.isActive
                        ? const Color(0xFFE4F3EF)
                        : const Color(0xFFF0F2F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    teacher.isActive ? 'Actif' : 'Désactivé',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: teacher.isActive
                ? 'Désactiver le compte de ' + teacher.name
                : 'Activer le compte de ' + teacher.name,
            child: Switch.adaptive(
              value: teacher.isActive,
              onChanged: onActiveChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTeachersState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyTeachersState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.teal.withAlpha(24),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.group_outlined, color: AppColors.teal, size: 28),
          ),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk, height: 1.4)),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  final String message;
  const _InlineNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: colors.onErrorContainer))),
        ],
      ),
    );
  }
}
