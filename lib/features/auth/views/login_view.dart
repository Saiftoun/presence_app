import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_message_banner.dart';
import '../controllers/auth_controller.dart';
import 'auth_ui.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context
        .read<AuthController>()
        .signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez votre adresse e-mail d’abord.')),
      );
      return;
    }
    final ok = await context.read<AuthController>().resetPassword(email);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail de réinitialisation envoyé.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return AuthShell(
      title: 'Bienvenue',
      subtitle: 'Connectez-vous pour accéder à votre espace.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Saisissez votre adresse e-mail';
                if (!email.contains('@') || !email.split('@').last.contains('.')) {
                  return 'Adresse e-mail invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Saisissez votre mot de passe'
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: auth.isLoading ? null : _forgotPassword,
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            if (auth.error != null) ...[
              AppMessageBanner(message: auth.error!, isError: true),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Se connecter'),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Flexible(child: Text('Nouveau sur Présence ?')),
          TextButton(
            onPressed: auth.isLoading
                ? null
                : () {
                    context.read<AuthController>().clearError();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterView()),
                    );
                  },
            child: const Text('Créer un compte'),
          ),
        ],
      ),
    );
  }
}
