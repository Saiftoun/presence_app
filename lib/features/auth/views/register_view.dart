import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_message_banner.dart';
import '../controllers/auth_controller.dart';
import 'auth_ui.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _passwordObscure = true;
  bool _confirmObscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthController>().registerStudent(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (ok && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return AuthShell(
      title: 'Créer un compte',
      subtitle: 'Inscrivez-vous pour accéder à votre espace étudiant.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppMessageBanner(
              message: 'Les inscriptions publiques sont réservées aux étudiants. Les comptes enseignants sont créés par l’administration.',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => value == null || value.trim().length < 3
                  ? 'Saisissez au moins 3 caractères'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newUsername],
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty || !email.contains('@') || !email.split('@').last.contains('.')) {
                  return 'Saisissez une adresse e-mail valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _passwordObscure,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                helperText: '6 caractères minimum',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _passwordObscure ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                  icon: Icon(_passwordObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _passwordObscure = !_passwordObscure),
                ),
              ),
              validator: (value) => value == null || value.length < 6
                  ? 'Utilisez au moins 6 caractères'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _confirmObscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: const Icon(Icons.lock_reset_rounded),
                suffixIcon: IconButton(
                  tooltip: _confirmObscure ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                  icon: Icon(_confirmObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _confirmObscure = !_confirmObscure),
                ),
              ),
              validator: (value) => value != _passwordCtrl.text
                  ? 'Les mots de passe ne correspondent pas'
                  : null,
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 16),
              AppMessageBanner(message: auth.error!, isError: true),
            ],
            const SizedBox(height: 22),
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
                  : const Text('Créer mon compte étudiant'),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Flexible(child: Text('Vous avez déjà un compte ?')),
          TextButton(
            onPressed: auth.isLoading ? null : () => Navigator.of(context).maybePop(),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }
}
