import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neo_code/i18n/strings.g.dart';
import 'package:neo_code/ui/theme/neo_theme.dart';
import 'package:neo_code/project/project_provider.dart';

class WelcomeView extends ConsumerWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neo = Theme.of(context).extension<NeoTheme>()!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.code_rounded, size: 64, color: neo.accentColor),
          const SizedBox(height: 16),
          Text(
            t.ui.welcome.title,
            style: TextStyle(
              color: neo.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.ui.welcome.subtitle,
            style: TextStyle(
              color: neo.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 220,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () =>
                  ref.read(projectProvider.notifier).openNewProject(),
              icon: const Icon(Icons.folder_open_outlined, size: 20),
              label: Text(
                t.ui.welcome.openProject,
                style: const TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: neo.accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
