import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neo_code/ui/theme/neo_theme.dart';
import 'package:neo_code/ui/views/welcome_view.dart';
import 'package:neo_code/ui/views/main_editor_view.dart';
import 'package:neo_code/project/project_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neo = Theme.of(context).extension<NeoTheme>()!;
    final projectAsync = ref.watch(projectProvider);

    return Container(
      color: neo.editorBg,
      child: projectAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: neo.accentColor),
        ),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: TextStyle(color: neo.textPrimary),
          ),
        ),
        data: (projectPath) {
          if (projectPath == null) {
            return const WelcomeView();
          }
          return MainEditorView(projectPath: projectPath);
        },
      ),
    );
  }
}
