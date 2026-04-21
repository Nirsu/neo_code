import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'package:neo_code/i18n/strings.g.dart';
import 'package:neo_code/ui/theme/neo_theme.dart';
import 'package:neo_code/ui/widgets/activity_bar.dart';
import 'package:neo_code/ui/widgets/file_tree.dart';
import 'package:neo_code/ui/widgets/code_editor.dart';

class MainEditorView extends ConsumerStatefulWidget {
  final String projectPath;

  const MainEditorView({super.key, required this.projectPath});

  @override
  ConsumerState<MainEditorView> createState() => _MainEditorViewState();
}

class _MainEditorViewState extends ConsumerState<MainEditorView> {
  bool _sidebarVisible = true;
  bool _chatVisible = false;
  int _activeIndex = 0;
  MultiSplitViewController? _splitController;

  void _toggleChat() {
    setState(() {
      _chatVisible = !_chatVisible;
      if (_chatVisible) {
        _activeIndex = 2;
      }
      _rebuildController();
    });
  }

  void _onIconTap(int index) {
    setState(() {
      switch (index) {
        case 0:
          _activeIndex = 0;
          if (!_sidebarVisible) {
            _sidebarVisible = true;
            _rebuildController();
          }
        case 1:
          _activeIndex = 1;
        case 2:
          _toggleChat();
          return;
        case 3:
          _activeIndex = 3;
      }
    });
  }

  void _rebuildController() {
    _splitController?.dispose();
    _splitController = null;
  }

  MultiSplitViewController _getController() {
    final areas = <Area>[
      if (_sidebarVisible)
        Area(
          size: 250,
          min: 150,
          builder: (_, _) => _Sidebar(projectPath: widget.projectPath),
        ),
      Area(
        flex: 1,
        min: 300,
        builder: (_, _) => const CodeEditorArea(),
      ),
      if (_chatVisible)
        Area(
          size: 350,
          min: 200,
          builder: (_, _) => const _ChatPanel(),
        ),
    ];

    final ctrl = MultiSplitViewController(areas: areas);
    _splitController = ctrl;
    return ctrl;
  }

  @override
  void dispose() {
    _splitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neo = Theme.of(context).extension<NeoTheme>()!;

    return Container(
      color: neo.editorBg,
      child: Row(
        children: [
          ActivityBar(
            activeIndex: _activeIndex,
            onIconTap: _onIconTap,
            neoTheme: neo,
          ),
          Expanded(
            child: MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                dividerThickness: 4,
                dividerPainter: DividerPainters.background(
                  color: neo.dividerColor,
                  highlightedColor: neo.accentColor,
                ),
              ),
              child: MultiSplitView(
                controller:
                    _splitController ?? _getController(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String projectPath;

  const _Sidebar({required this.projectPath});

  @override
  Widget build(BuildContext context) {
    final neo = Theme.of(context).extension<NeoTheme>()!;

    return Container(
      color: neo.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              t.ui.sidebar.header,
              style: TextStyle(
                color: neo.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: neo.dividerColor),
          Expanded(child: FileTree(projectPath: projectPath)),
        ],
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel();

  @override
  Widget build(BuildContext context) {
    final neo = Theme.of(context).extension<NeoTheme>()!;

    return Container(
      color: neo.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              t.ui.chat.header,
              style: TextStyle(
                color: neo.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: neo.dividerColor),
          Expanded(
            child: Center(
              child: Text(
                t.ui.chat.placeholder,
                style: TextStyle(color: neo.textSecondary, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
