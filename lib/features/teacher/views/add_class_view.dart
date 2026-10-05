import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/class_controller.dart';
import '../models/school_class.dart';

class AddClassView extends StatefulWidget {
  /// null = creating a new class, otherwise editing this one.
  final SchoolClass? existing;
  const AddClassView({super.key, this.existing});

  @override
  State<AddClassView> createState() => _AddClassViewState();
}

class _AddClassViewState extends State<AddClassView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _levelCtrl;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _levelCtrl = TextEditingController(text: widget.existing?.level ?? '');
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ClassController>().clearError());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _levelCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<ClassController>().saveClass(
          classId: widget.existing?.id,
          name: _nameCtrl.text.trim(),
          level: _levelCtrl.text.trim(),
        );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Classe modifiée.' : 'Classe créée.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ClassController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la classe' : 'Nouvelle classe'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la classe',
                        hintText: 'Ex : DSI 3.1',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Nom requis'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _levelCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Niveau',
                        hintText: 'Ex : 3ème année Licence',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Niveau requis'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    if (ctrl.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(ctrl.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    FilledButton(
                      onPressed: ctrl.isSaving ? null : _submit,
                      child: ctrl.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isEditing ? 'Enregistrer' : 'Créer la classe'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}