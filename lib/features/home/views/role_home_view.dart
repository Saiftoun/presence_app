import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/app_user.dart';

class RoleHomeView extends StatelessWidget {
  final String title;
  final AppUser user;

  const RoleHomeView({super.key, required this.title, required this.user});

  @override
  Widget build(BuildContext context) {
    final isTeacher = user.role == UserRole.teacher;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
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
                  isTeacher
                      ? 'Votre espace enseignant est prêt.'
                      : 'Votre espace étudiant est prêt.',
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
                Container(
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
                        child: Text(
                          user.name.trim().isEmpty
                              ? '?'
                              : user.name.trim().substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4F3EF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isTeacher ? 'Enseignant' : 'Étudiant',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.tealDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
