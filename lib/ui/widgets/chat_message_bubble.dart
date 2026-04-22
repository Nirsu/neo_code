import 'package:flutter/material.dart';
import 'package:neo_code/ui/theme/neo_theme.dart';

class ChatMessageBubble extends StatelessWidget {
  final String role;
  final String content;

  const ChatMessageBubble({
    super.key,
    required this.role,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final neo = Theme.of(context).extension<NeoTheme>()!;

    if (role == 'user') {
      return _buildUserBubble(neo);
    }
    return _buildAssistantMessage(neo);
  }

  Widget _buildUserBubble(NeoTheme neo) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2128),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: SelectableText(
          content,
          style: TextStyle(
            color: neo.textPrimary,
            fontSize: 13,
            fontFamily: 'Consolas',
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(NeoTheme neo) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8, top: 2),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: neo.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.smart_toy_outlined,
                  size: 16, color: neo.accentColor),
            ),
            Expanded(
              child: SelectableText(
                content,
                style: TextStyle(
                  color: neo.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
