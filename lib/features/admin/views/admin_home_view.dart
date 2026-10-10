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
      child: const _AdminNavigationShell(),
    );
  }
}

class _AdminNavigationShell extends StatefulWidget {
  const _AdminNavigationShell();

  @override
  State<_AdminNavigationShell> createState() => _AdminNavigationShellState();
}

class _AdminNavigationShellState extends State<_AdminNavigationShell> {
  int _selectedIndex = 0;

  static const _titles = ['Accueil', 'Enseignants', 'Classes', 'Étudiants', 'Séances'];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _AdminOverviewView(onNavigate: (index) => setState(() => _selectedIndex = index)),
      const TeachersListView(),
      const _AdminPlaceholderView(
        icon: Icons.class_outlined,
        title: 'Gestion des classes',
        description: 'Les classes et leurs groupes apparaîtront ici lorsqu’ils seront configurés.',
      ),
      const _AdminPlaceholderView(
        icon: Icons.groups_2_outlined,
        title: 'Gestion des étudiants',
        description: 'Les comptes étudiants et leur affectation aux classes seront gérés ici.',
      ),
      const _AdminPlaceholderView(
        icon: Icons.event_note_outlined,
        title: 'Gestion des séances',
        description: 'Les séances créées par l’administration seront organisées ici.',
      ),
    ];

    return Scaffold(
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
            Text(_titles[_selectedIndex]),
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
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
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
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Enseignants',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_rounded),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_2_outlined),
            selectedIcon: Icon(Icons.groups_2_rounded),
            label: 'Étudiants',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Séances',
          ),
        ],
      ),
    );
  }
}

class _AdminOverviewView extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _AdminOverviewView({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeacherController>();
    final activeCount = controller.teachers.where((teacher) => teacher.isActive).length;
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
          children: [
            Text(
              'Votre établissement, en un seul endroit.',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gérez les accès, les classes et les séances depuis votre espace administrateur.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, Color(0xFF24566B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0x26FFFFFF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Espace administrateur',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Les outils sont regroupés par domaine de gestion.',
                          style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xD9FFFFFF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withAlpha(24),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.school_outlined, color: AppColors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Équipe enseignante', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(
                          controller.isLoading
                              ? 'Chargement des comptes…'
                              : controller.teachers.length.toString() + ' comptes · ' + activeCount.toString() + ' actifs',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Ouvrir les enseignants',
                    onPressed: () => onNavigate(1),
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ACCÈS RAPIDE',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.mutedInk,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _AdminShortcut(
                      width: width,
                      icon: Icons.school_outlined,
                      title: 'Enseignants',
                      subtitle: 'Gérer les accès',
                      onTap: () => onNavigate(1),
                    ),
                    _AdminShortcut(
                      width: width,
                      icon: Icons.class_outlined,
                      title: 'Classes',
                      subtitle: 'Organisation',
                      onTap: () => onNavigate(2),
                    ),
                    _AdminShortcut(
                      width: width,
                      icon: Icons.groups_2_outlined,
                      title: 'Étudiants',
                      subtitle: 'Comptes et groupes',
                      onTap: () => onNavigate(3),
                    ),
                    _AdminShortcut(
                      width: width,
                      icon: Icons.event_note_outlined,
                      title: 'Séances',
                      subtitle: 'Planification',
                      onTap: () => onNavigate(4),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminShortcut extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminShortcut({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.teal, size: 23),
                const SizedBox(height: 10),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminPlaceholderView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AdminPlaceholderView({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withAlpha(24),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Icon(icon, color: AppColors.teal, size: 29),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3D6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PROCHAINE ÉTAPE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF805B13),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
