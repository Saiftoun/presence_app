import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_message_banner.dart';
import '../controllers/admin_class_controller.dart';
import '../models/academic_class.dart';
import 'class_details_view.dart';

class AdminClassesView extends StatefulWidget {
  const AdminClassesView({super.key});

  @override
  State<AdminClassesView> createState() => _AdminClassesViewState();
}

class _AdminClassesViewState extends State<AdminClassesView> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _showArchived = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminClassController>();
    final activeCount = controller.classes.where((item) => item.isActive).length;
    final archivedCount = controller.classes.length - activeCount;
    final query = _query.trim().toLowerCase();
    final classes = controller.classes.where((item) {
      if (item.isActive == _showArchived) return false;
      final teacher = controller.teacherName(item.teacherId).toLowerCase();
      return item.name.toLowerCase().contains(query) ||
          item.group.toLowerCase().contains(query) ||
          teacher.contains(query);
    }).toList();
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 112),
          children: [
            Text(
              'Gestion des classes',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Organisez les groupes, désignez un enseignant et inscrivez les étudiants.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk, height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(child: _ClassCount(value: activeCount.toString(), label: 'Actives')),
                  Container(width: 1, height: 36, color: const Color(0x44FFFFFF)),
                  Expanded(child: _ClassCount(value: archivedCount.toString(), label: 'Archivées')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Rechercher une classe, un groupe ou un enseignant',
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text('Actives ($activeCount)'),
                  selected: !_showArchived,
                  onSelected: (_) => setState(() => _showArchived = false),
                ),
                ChoiceChip(
                  label: Text('Archivées ($archivedCount)'),
                  selected: _showArchived,
                  onSelected: (_) => setState(() => _showArchived = true),
                ),
              ],
            ),
            if (controller.error != null) ...[
              const SizedBox(height: 14),
              AppMessageBanner(message: controller.error!, isError: true),
            ],
            const SizedBox(height: 16),
            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (classes.isEmpty)
              _ClassesEmptyState(
                archived: _showArchived,
                searched: query.isNotEmpty,
              )
            else ...[
              Text(
                _showArchived ? 'CLASSES ARCHIVÉES' : 'CLASSES ACTIVES',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedInk,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              for (final academicClass in classes)
                _ClassCard(
                  academicClass: academicClass,
                  teacherName: controller.teacherName(academicClass.teacherId),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ClassDetailsView(classId: academicClass.id),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClassCount extends StatelessWidget {
  final String value;
  final String label;

  const _ClassCount({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xD9FFFFFF))),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final AcademicClass academicClass;
  final String teacherName;
  final VoidCallback onTap;

  const _ClassCard({required this.academicClass, required this.teacherName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.teal.withAlpha(24), borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.class_outlined, color: AppColors.teal),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(academicClass.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink)),
                    const SizedBox(height: 4),
                    Text(
                      academicClass.group.isEmpty ? 'Sans groupe' : academicClass.group,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _ClassMeta(icon: Icons.school_outlined, label: teacherName),
                        _ClassMeta(icon: Icons.people_outline_rounded, label: academicClass.studentIds.length.toString() + ' étudiants'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ClassMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mutedInk),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.mutedInk)),
      ],
    );
  }
}

class _ClassesEmptyState extends StatelessWidget {
  final bool archived;
  final bool searched;

  const _ClassesEmptyState({required this.archived, required this.searched});

  @override
  Widget build(BuildContext context) {
    final title = searched
        ? 'Aucun résultat'
        : archived
            ? 'Aucune classe archivée'
            : 'Aucune classe pour le moment';
    final message = searched
        ? 'Essayez un autre nom, groupe ou enseignant.'
        : archived
            ? 'Les classes archivées apparaîtront ici.'
            : 'Ajoutez une classe pour commencer à organiser les groupes et les inscriptions.';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          const Icon(Icons.class_outlined, size: 42, color: AppColors.teal),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk, height: 1.4)),
        ],
      ),
    );
  }
}
