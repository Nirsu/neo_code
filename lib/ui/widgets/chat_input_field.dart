import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_code/ui/theme/neo_theme.dart';
import 'package:neo_code/database/database.dart' as db;
import 'package:neo_code/chat/chat_session_provider.dart' show allChatSessionsProvider;

class ChatInputField extends ConsumerStatefulWidget {
  final ValueChanged<String> onSend;

  const ChatInputField({super.key, required this.onSend});

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showMentions = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    if (cursorPos < 0) {
      if (_showMentions) setState(() => _showMentions = false);
      return;
    }

    final textBeforeCursor = text.substring(0, cursorPos);
    final atIndex = textBeforeCursor.lastIndexOf('@');

    if (atIndex >= 0) {
      final afterAt = textBeforeCursor.substring(atIndex + 1);
      final hasSpace = afterAt.contains(' ');
      final hasChatPrefix = afterAt.startsWith('chat:');
      if (!hasSpace && !hasChatPrefix && afterAt.length < 20) {
        if (!_showMentions) setState(() => _showMentions = true);
        return;
      }
    }
    if (_showMentions) setState(() => _showMentions = false);
  }

  void _insertMention(db.ChatSession session) {
    final text = _controller.text;
    final cursorPos = _controller.selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPos);
    final atIndex = textBeforeCursor.lastIndexOf('@');

    if (atIndex >= 0) {
      final before = text.substring(0, atIndex);
      final after = text.substring(cursorPos);
      final tag = '@chat:${session.id}';
      _controller.text = '$before$tag $after';
      _controller.selection = TextSelection.collapsed(
        offset: before.length + tag.length + 1,
      );
    }
    setState(() => _showMentions = false);
    _focusNode.requestFocus();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _showMentions = false);
    widget.onSend(text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neo = Theme.of(context).extension<NeoTheme>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showMentions) _buildMentionsOverlay(neo),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: neo.dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 4,
                  minLines: 1,
                  style: TextStyle(
                    color: neo.textPrimary,
                    fontSize: 13,
                    fontFamily: 'Consolas',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Message... (@ pour référencer un chat)',
                    hintStyle: TextStyle(
                        color: neo.textSecondary,
                        fontSize: 13,
                        fontFamily: 'Consolas'),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _handleSend,
                icon: Icon(Icons.send_rounded, size: 18, color: neo.accentColor),
                style: IconButton.styleFrom(
                  backgroundColor: neo.accentColor.withValues(alpha: 0.1),
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMentionsOverlay(NeoTheme neo) {
    final sessionsAsync = ref.watch(allChatSessionsProvider);

    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: neo.dividerColor),
      ),
      child: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Aucun chat disponible',
                  style: TextStyle(color: neo.textSecondary, fontSize: 12)),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: sessions.length,
            itemBuilder: (_, i) {
              final s = sessions[i];
              return InkWell(
                onTap: () => _insertMention(s),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 14, color: neo.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '#${s.id} ${s.title}',
                          style: TextStyle(
                              color: neo.textPrimary,
                              fontSize: 12,
                              fontFamily: 'Consolas'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}
