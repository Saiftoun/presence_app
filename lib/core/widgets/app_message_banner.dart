import 'package:flutter/material.dart';

class AppMessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const AppMessageBanner({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isError ? colors.errorContainer : colors.secondaryContainer;
    final foreground = isError ? colors.onErrorContainer : colors.onSecondaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            color: foreground,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foreground, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
