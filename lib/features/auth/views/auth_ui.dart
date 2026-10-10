import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final Widget? footer;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF2F5), Color(0xFFF8FAFB), Color(0xFFEFF7F5)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _AuthBrandHeader(),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.outline),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D17384F),
                            blurRadius: 28,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedInk,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 24),
                          form,
                          if (footer != null) ...[
                            const SizedBox(height: 14),
                            footer!,
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'GESTION ACADÉMIQUE · ACCÈS SÉCURISÉ',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.mutedInk,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
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

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A17384F),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(Icons.fact_check_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          'PRÉSENCE',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Le suivi académique, simplement.',
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
        ),
      ],
    );
  }
}
