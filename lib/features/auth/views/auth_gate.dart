import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../admin/views/admin_home_view.dart';
import '../../home/views/role_home_view.dart';
import '../controllers/auth_controller.dart';
import '../models/app_user.dart';
import 'login_view.dart';
import 'splash_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    switch (auth.status) {
      case AuthStatus.checking:
        return const SplashView();
      case AuthStatus.unauthenticated:
        return const LoginView();
      case AuthStatus.profileError:
        return AccountProfileErrorView(
          message: auth.error ?? 'Le profil de ce compte est indisponible.',
        );
      case AuthStatus.authenticated:
        return _homeFor(auth.user);
    }
  }

  Widget _homeFor(AppUser? user) {
    if (user == null || user.role == UserRole.unknown) {
      return const AccountProfileErrorView(
        message: 'Rôle utilisateur invalide. Contactez un administrateur.',
      );
    }

    switch (user.role) {
      case UserRole.admin:
        return const AdminHomeView();
      case UserRole.teacher:
      case UserRole.student:
        return RoleHomeView(title: user.role.dashboardTitle, user: user);
      case UserRole.unknown:
        return const AccountProfileErrorView(
          message: 'Rôle utilisateur invalide. Contactez un administrateur.',
        );
    }
  }
}

class AccountProfileErrorView extends StatelessWidget {
  final String message;
  const AccountProfileErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.read<AuthController>().signOut(),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
