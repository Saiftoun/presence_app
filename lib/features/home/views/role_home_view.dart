import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/app_user.dart';

class RoleHomeView extends StatefulWidget {
  final String title;
  final AppUser user;

  const RoleHomeView({super.key, required this.title, required this.user});

  @override
  State<RoleHomeView> createState() => _RoleHomeViewState();
}

class _RoleHomeViewState extends State<RoleHomeView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.user.role == UserRole.teacher;
    final pages = isTeacher
        ? <Widget>[
            _RoleDashboardPage(user: widget.user, isTeacher: true),
            const _RoleEmptyPage(
              icon: Icons.event_note_outlined,
              title: 'Aucune séance à afficher',
              description: 'Les séances créées par l’administration apparaîtront ici.',
            ),
            const _RoleEmptyPage(
              icon: Icons.fact_check_outlined,
              title: 'Suivi des présences',
              description: 'Les présences des étudiants et la vôtre pendant chaque séance apparaîtront ici.',
            ),
            _RoleProfilePage(user: widget.user, isTeacher: true),
          ]
        : <Widget>[
            _RoleDashboardPage(user: widget.user, isTeacher: false),
            const _RoleEmptyPage(
              icon: Icons.fact_check_outlined,
              title: 'Mon suivi de présence',
              description: 'Vos présences et votre historique apparaîtront ici après vos premières séances.',
            ),
            _RoleProfilePage(user: widget.user, isTeacher: false),
          ];
    final destinations = isTeacher
        ? const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Accueil'),
            NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note_rounded), label: 'Séances'),
            NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check_rounded), label: 'Présences'),
            NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ]
        : const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Accueil'),
            NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check_rounded), label: 'Présences'),
            NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthController>().signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: destinations,
      ),
    );
  }
}

class _RoleDashboardPage extends StatelessWidget {
  final AppUser user;
  final bool isTeacher;

  const _RoleDashboardPage({required this.user, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: [
            Text(
              'Bonjour, ' + user.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              isTeacher ? 'Votre espace enseignant est prêt.' : 'Votre espace étudiant est prêt.',
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.mutedInk),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.navy, Color(0xFF24566B)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0x26FFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isTeacher ? Icons.co_present_rounded : Icons.event_available_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    isTeacher ? 'ESPACE ENSEIGNANT' : 'ESPACE ÉTUDIANT',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xD9FFFFFF),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTeacher
                        ? 'La gestion des séances et le suivi des présences seront centralisés ici.'
                        : 'Vos séances et votre historique de présence seront centralisés ici.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _RoleProfileCard(user: user, isTeacher: isTeacher),
          ],
        ),
      ),
    );
  }
}

class _RoleProfilePage extends StatelessWidget {
  final AppUser user;
  final bool isTeacher;

  const _RoleProfilePage({required this.user, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Mon profil', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Informations de votre compte.', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk)),
              const SizedBox(height: 18),
              _RoleProfileCard(user: user, isTeacher: isTeacher),
              const SizedBox(height: 18),
              const _AccountStatusCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleProfileCard extends StatelessWidget {
  final AppUser user;
  final bool isTeacher;

  const _RoleProfileCard({required this.user, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user.name.trim();
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.teal.withAlpha(24),
            foregroundColor: AppColors.tealDark,
            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: theme.textTheme.titleSmall?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFFE4F3EF), borderRadius: BorderRadius.circular(20)),
            child: Text(
              isTeacher ? 'Enseignant' : 'Étudiant',
              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.tealDark, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: AppColors.tealDark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Compte actif',
              style: theme.textTheme.titleSmall?.copyWith(color: AppColors.tealDark, fontWeight: FontWeight.w700),
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.teal),
        ],
      ),
    );
  }
}

class _RoleEmptyPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _RoleEmptyPage({required this.icon, required this.title, required this.description});

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
                  decoration: BoxDecoration(color: AppColors.teal.withAlpha(24), borderRadius: BorderRadius.circular(19)),
                  child: Icon(icon, color: AppColors.teal, size: 29),
                ),
                const SizedBox(height: 18),
                Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(description, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk, height: 1.45)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
