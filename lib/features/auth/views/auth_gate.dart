import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/views/role_home_view.dart';
import '../controllers/auth_controller.dart';
import '../models/app_user.dart';
import 'login_view.dart';
import 'splash_view.dart';
import '../../teacher/views/teacher_home_view.dart';
import '../../admin/views/admin_home_view.dart';
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
      case AuthStatus.authenticated:
        switch (auth.user!.role) {
       case UserRole.admin:
            return const AdminHomeView();
       case UserRole.teacher:
            return const TeacherHomeView();
          case UserRole.student:
            return const RoleHomeView(title: 'Espace Étudiant');
        }
    }
  }
}