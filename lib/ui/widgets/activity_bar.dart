import 'package:flutter/material.dart';

import 'package:neo_code/i18n/strings.g.dart';
import 'package:neo_code/ui/theme/neo_theme.dart';

class ActivityBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onIconTap;
  final NeoTheme neoTheme;

  const ActivityBar({
    super.key,
    required this.activeIndex,
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
