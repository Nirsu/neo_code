import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neo_code/i18n/strings.g.dart';
import 'package:neo_code/ui/theme/neo_theme.dart';
import 'package:neo_code/chat/chat_session_provider.dart';import 'package:neo_code/chat/message_list_provider.dart';import 'package:neo_code/ui/widgets/chat_message_bubble.dart';
import 'package:neo_code/ui/widgets/chat_input_field.dart';

class ChatPanel extends ConsumerStatefulWidget {
  const ChatPanel({super.key});

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(String text) async {
    final sessionId = ref.read(activeChatSessionProvider);
    if (sessionId == null) {
      await ref.read(activeChatSessionProvider.notifier).createNew();
    }
    _scrollToBottom();
    await ref.read(messageListProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final neo = Theme.of(context).extension<NeoTheme>()!;
    final sessionId = ref.watch(activeChatSessionProvider);
    final messagesAsync = ref.watch(messageListProvider);

    return Container(
      color: neo.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(neo, sessionId),
          Divider(height: 1, thickness: 1, color: neo.dividerColor),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.smart_toy_outlined,
                              size: 40,
                              color: neo.textSecondary
                                  .withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'Neo Assistant',
                            style: TextStyle(
                              color: neo.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pose une question ou tape @ pour\nréférencer un autre chat',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: neo.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    return ChatMessageBubble(
                      role: msg.role,
                      content: msg.content,
                    );
                  },
                );
              },
              loading: () => Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: neo.accentColor,
                  ),
                ),
              ),
              error: (e, _) => Center(
                child: Text('Erreur: $e',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
          ),
          ChatInputField(onSend: _handleSend),
        ],
      ),
    );
  }

  Widget _buildHeader(NeoTheme neo, int? sessionId) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            t.ui.chat.header,
            style: TextStyle(
              color: neo.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          if (sessionId != null)
            Tooltip(
              message: 'Nouveau chat',
              child: IconButton(
                onPressed: () => ref
                    .read(activeChatSessionProvider.notifier)
                    .createNew(),
                icon: Icon(Icons.add, size: 18, color: neo.textSecondary),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ),
        ],
      ),
    );
  }
}
