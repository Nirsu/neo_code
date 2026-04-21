import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:code_forge/code_forge.dart';
import 'package:re_highlight/languages/dart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MultiSplitViewController _splitController = MultiSplitViewController(
    areas: [
      /// Sidebar gauche étroite (Explorateur)
      Area(
        size: 250,
        min: 150,
        builder: (context, area) => const _LeftSidebar(),
      ),

      /// Zone centrale large (Éditeur)
      Area(
        flex: 1,
        min: 300,
        builder: (context, area) => const _CodeEditorArea(),
      ),

      /// Sidebar droite (Chat IA)
      Area(
        size: 300,
        min: 200,
        builder: (context, area) => const _RightSideChat(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E), // Couleur de fond IDE typique
      child: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 4,
          dividerPainter: DividerPainters.background(
            color: const Color(0xFF2D2D2D), // Séparateur discret
            highlightedColor: const Color(0xFF007ACC), // Survol
          ),
        ),
        child: MultiSplitView(controller: _splitController),
      ),
    );
  }
}

class _LeftSidebar extends StatelessWidget {
  const _LeftSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF252526),
      child: const Center(
        child: Text(
          'Explorateur (Futur)',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class _RightSideChat extends StatelessWidget {
  const _RightSideChat();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF252526),
      child: const Center(
        child: Text('Chat IA (Futur)', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}

class _CodeEditorArea extends StatefulWidget {
  const _CodeEditorArea();

  @override
  State<_CodeEditorArea> createState() => _CodeEditorAreaState();
}

class _CodeEditorAreaState extends State<_CodeEditorArea> {
  late final CodeForgeController _codeController;

  @override
  void initState() {
    super.initState();
    // Initialise le contrôleur basique de l'éditeur de `code_forge`.
    // (Note: L'API récente de `code_forge` nomme cela `CodeForgeController`).
    _codeController = CodeForgeController();

    // Code de départ pour l'exemple
    _codeController.text = '''/// Neo Code - Editeur Dart
void main() {
  print('Neo Code est prêt !');
}
''';
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      // Le widget principal d'édition (`CodeEditor` dans vos specs, nommé ici `CodeForge`)
      child: CodeForge(
        controller: _codeController,
        language: langDart, // Coloration syntaxique Dart via re_highlight
        textStyle: const TextStyle(
          fontFamily: 'Consolas',
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
