import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';

class RoleHomeView extends StatelessWidget {
  final String title;
  const RoleHomeView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user!;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthController>().signOut(),
          ),
        ],
      ),
      body: Center(
        child: Text('Bonjour ${user.name}\nRôle : ${user.role.name}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}