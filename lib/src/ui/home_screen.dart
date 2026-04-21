import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:code_forge/code_forge.dart';
import 'package:re_highlight/languages/dart.dart';

import 'package:neo_code/i18n/strings.g.dart';
import 'package:neo_code/src/ui/theme/neo_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _sidebarVisible = true;
  bool _chatVisible = false;
  int _activeIndex = 0;

  void _toggleSidebar() {
    setState(() {
      _sidebarVisible = !_sidebarVisible;
      if (!_sidebarVisible && _activeIndex == 0) {
        _activeIndex = -1;
      } else if (_sidebarVisible && _activeIndex == -1) {
        _activeIndex = 0;
      }
    });
  }

  void _toggleChat() {
    setState(() {
      _chatVisible = !_chatVisible;
      if (_chatVisible) {
        _activeIndex = 2;
      }
    });
  }

  void _onIconTap(int index) {
    setState(() {
      switch (index) {
        case 0:
          _activeIndex = 0;
          if (!_sidebarVisible) _sidebarVisible = true;
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

  List<Area> _buildAreas() {
    return [
      if (_sidebarVisible)
        Area(
          size: 250,
          min: 150,
          builder: (_, __) => const _Sidebar(),
        ),
      Area(
        flex: 1,
        min: 300,
        builder: (_, __) => const _CodeEditorArea(),
      ),
      if (_chatVisible)
        Area(
          size: 350,
          min: 200,
          builder: (_, __) => const _ChatPanel(),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final neo = Theme.of(context).extension<NeoTheme>()!;

    return Container(
      color: neo.editorBg,
      child: Row(
        children: [
          _ActivityBar(
            activeIndex: _activeIndex,
            chatVisible: _chatVisible,
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
                controller: MultiSplitViewController(areas: _buildAreas()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityBar extends StatelessWidget {
  final int activeIndex;
  final bool chatVisible;
  final ValueChanged<int> onIconTap;
  final NeoTheme neoTheme;

  const _ActivityBar({
    required this.activeIndex,
    required this.chatVisible,
    required this.onIconTap,
    required this.neoTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      color: neoTheme.sidebarBg,
      child: Column(
        children: [
          _ActivityIcon(
            icon: Icons.folder_outlined,
            tooltip: t.ui.activityBar.explorer,
            isActive: activeIndex == 0,
            onTap: () => onIconTap(0),
            neoTheme: neoTheme,
          ),
          _ActivityIcon(
            icon: Icons.search,
            tooltip: t.ui.activityBar.search,
            isActive: activeIndex == 1,
            onTap: () => onIconTap(1),
            neoTheme: neoTheme,
          ),
          _ActivityIcon(
            icon: Icons.chat_bubble_outline,
            tooltip: t.ui.activityBar.chat,
            isActive: activeIndex == 2,
            onTap: () => onIconTap(2),
            neoTheme: neoTheme,
          ),
          const Spacer(),
          _ActivityIcon(
            icon: Icons.settings_outlined,
            tooltip: t.ui.activityBar.settings,
            isActive: activeIndex == 3,
            onTap: () => onIconTap(3),
            neoTheme: neoTheme,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ActivityIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;
  final NeoTheme neoTheme;

  const _ActivityIcon({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
    required this.neoTheme,
  });

  @override
  State<_ActivityIcon> createState() => _ActivityIconState();
}

class _ActivityIconState extends State<_ActivityIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final neo = widget.neoTheme;
    final color =
        widget.isActive ? neo.accentColor : neo.textSecondary;
    final bgColor =
        widget.isActive
            ? neo.hoverBg
            : _isHovered
                ? neo.hoverBg
                : Colors.transparent;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      preferBelow: false,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 50,
            height: 50,
            color: bgColor,
            child: Stack(
              children: [
                if (widget.isActive)
                  Positioned(
                    left: 0,
                    top: 8,
                    bottom: 8,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: neo.accentColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                Center(child: Icon(widget.icon, size: 24, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

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
          Divider(
            height: 1,
            thickness: 1,
            color: neo.dividerColor,
          ),
          Expanded(
            child: Center(
              child: Text(
                t.ui.sidebar.placeholder,
                style: TextStyle(color: neo.textSecondary, fontSize: 13),
              ),
            ),
          ),
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
          Divider(
            height: 1,
            thickness: 1,
            color: neo.dividerColor,
          ),
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
    _codeController = CodeForgeController();
    _codeController.text = '''/// Neo Code - Editeur Dart
void main() {
  print('${t.ui.editor.placeholder}');
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
    final neo = Theme.of(context).extension<NeoTheme>()!;

    return Container(
      color: neo.editorBg,
      child: CodeForge(
        controller: _codeController,
        language: langDart,
        textStyle: const TextStyle(
          fontFamily: 'Consolas',
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
