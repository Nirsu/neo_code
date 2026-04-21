import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_forge/code_forge.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/styles/github-dark.dart';

import 'package:neo_code/i18n/strings.g.dart';
import 'package:neo_code/ui/theme/neo_theme.dart';
import 'package:neo_code/project/active_file_provider.dart';

class CodeEditorArea extends ConsumerStatefulWidget {
  const CodeEditorArea({super.key});

  @override
  ConsumerState<CodeEditorArea> createState() => _CodeEditorAreaState();
}

class _CodeEditorAreaState extends ConsumerState<CodeEditorArea> {
  late final CodeForgeController _codeController;
  String? _displayedPath;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _codeController = CodeForgeController();
    _codeController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_isDirty && _displayedPath != null) {
      _isDirty = true;
    }
  }

  @override
  void dispose() {
    _codeController.removeListener(_onTextChanged);
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neo = Theme.of(context).extension<NeoTheme>()!;
    final filePath = ref.watch(activeFileProvider);

    if (filePath != _displayedPath) {
      if (_isDirty && _displayedPath != null) {
        _saveFile(_displayedPath!);
      }
      _isDirty = false;
      _displayedPath = filePath;
      _loadFile(filePath);
    }

    if (filePath == null) {
      return Container(
        color: neo.editorBg,
        child: Center(
          child: Text(
            t.ui.editor.noFileOpen,
            style: TextStyle(color: neo.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return CodeForge(
      controller: _codeController,
      language: langDart,
      editorTheme: githubDarkTheme,
      textStyle: const TextStyle(
        fontFamily: 'Consolas',
        fontSize: 14,
        height: 1.5,
      ),
      gutterStyle: GutterStyle(
        backgroundColor: const Color(0xff0d1117),
        activeLineNumberColor: neo.textPrimary,
        inactiveLineNumberColor: neo.textSecondary,
      ),
      selectionStyle: CodeSelectionStyle(
        cursorColor: const Color(0xff58a6ff),
        selectionColor: const Color(0x4026444d),
        cursorBubbleColor: const Color(0xff58a6ff),
      ),
    );
  }

  void _loadFile(String? path) {
    if (path == null) {
      _codeController.text = '';
      return;
    }
    try {
      final file = File(path);
      if (file.existsSync()) {
        _codeController.text = file.readAsStringSync();
      }
    } catch (_) {
      _codeController.text = '';
    }
  }

  void _saveFile(String path) {
    try {
      final file = File(path);
      file.writeAsStringSync(_codeController.text);
    } catch (_) {}
  }
}
