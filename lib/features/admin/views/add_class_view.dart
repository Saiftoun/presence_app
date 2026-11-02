import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_message_banner.dart';
import '../controllers/admin_class_controller.dart';
import '../models/academic_class.dart';

class AddClassView extends StatefulWidget {
  final AcademicClass? existing;

  const AddClassView({super.key, this.existing});

  @override
  State<AddClassView> createState() => _AddClassViewState();
}

class _AddClassViewState extends State<AddClassView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;
  late final TextEditingController _descriptionController;
  String? _teacherId;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _groupController = TextEditingController(text: widget.existing?.group ?? '');
    _descriptionController = TextEditingController(text: widget.existing?.description ?? '');
    _teacherId = widget.existing?.teacherId;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdminClassController>().clearError(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final teacherId = _teacherId;
    if (teacherId == null) return;

    final saved = await context.read<AdminClassController>().saveClass(
          classId: widget.existing?.id,
          name: _nameController.text.trim(),
          group: _groupController.text.trim(),
          description: _descriptionController.text.trim(),
          teacherId: teacherId,
        );
    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Classe mise à jour.' : 'Classe créée.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminClassController>();
    final theme = Theme.of(context);
    final selectedTeacherExists = controller.teachers.any((user) => user.uid == _teacherId);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Modifier la classe' : 'Nouvelle classe')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isEditing ? 'Mettre à jour la classe' : 'Créer une classe',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Choisissez un nom, un groupe et l’enseignant responsable.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'Nom de la classe',
                          hintText: 'Ex. Informatique appliquée',
                          prefixIcon: Icon(Icons.class_outlined),
                          counterText: '',
                        ),
                        validator: (value) => value == null || value.trim().length < 2
                            ? 'Saisissez au moins 2 caractères'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _groupController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        maxLength: 80,
                        decoration: const InputDecoration(
                          labelText: 'Groupe',
                          hintText: 'Ex. DSI 3.1',
                          prefixIcon: Icon(Icons.groups_outlined),
                          counterText: '',
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Le groupe est requis'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 2,
                        maxLines: 4,
                        maxLength: 1000,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes_rounded),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedTeacherExists ? _teacherId : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Enseignant responsable',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        items: controller.teachers.map((teacher) {
                          return DropdownMenuItem<String>(
                            value: teacher.uid,
                            enabled: teacher.isActive,
                            child: Text(
                              teacher.name.isEmpty ? teacher.email : teacher.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: controller.activeTeachers.isEmpty
                            ? null
                            : (value) => setState(() => _teacherId = value),
                        validator: (value) {
                          if (value == null) return 'Sélectionnez un enseignant';
                          if (!controller.activeTeachers.any((user) => user.uid == value)) {
                            return 'Choisissez un compte enseignant actif';
                          }
                          return null;
                        },
                      ),
                      if (controller.error != null) ...[
                        const SizedBox(height: 16),
                        AppMessageBanner(message: controller.error!, isError: true),
                      ],
                      if (!controller.isLoading && controller.activeTeachers.isEmpty) ...[
                        const SizedBox(height: 16),
                        const AppMessageBanner(
                          message: 'Créez ou réactivez un compte enseignant avant d’attribuer cette classe.',
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: controller.isSaving || controller.activeTeachers.isEmpty
                            ? null
                            : _submit,
                        child: controller.isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(_isEditing ? 'Enregistrer les modifications' : 'Créer la classe'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
