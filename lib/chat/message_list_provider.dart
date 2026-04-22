import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:neo_code/database/database.dart';
import 'package:neo_code/chat/chat_session_provider.dart' show activeChatSessionProvider;
import 'package:neo_code/ai/genkit_client.dart';

part 'message_list_provider.g.dart';

typedef ChatMessageItem = ({
  int id,
  int sessionId,
  String role,
  String content,
  DateTime timestamp,
});

@riverpod
class MessageList extends _$MessageList {
  @override
  Future<List<ChatMessageItem>> build() async {
    final sessionId = ref.watch(activeChatSessionProvider);
    if (sessionId == null) return [];
    final db = ref.read(databaseProvider);
    final rows = await (db.chatMessages.select()
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
    return rows
        .map((m) => (
              id: m.id,
              sessionId: m.sessionId,
              role: m.role,
              content: m.content,
              timestamp: m.timestamp,
            ))
        .toList();
  }

  Future<void> sendMessage(String text) async {
    final sessionId = ref.read(activeChatSessionProvider);
    if (sessionId == null) return;
    final db = ref.read(databaseProvider);

    await db.into(db.chatMessages).insertReturning(
          ChatMessagesCompanion.insert(
            sessionId: sessionId,
            role: 'user',
            content: text,
          ),
        );

    ref.invalidateSelf();
    await future;

    final referencedContext = await _resolveReferences(text, db);
    final history = await _getRecentHistory(sessionId, db);

    final aiService = ref.read(aiServiceProvider);
    final response = await aiService.chatWithHistory(
      message: text,
      history: history,
      sharedContext: referencedContext,
    );

    await db.into(db.chatMessages).insertReturning(
          ChatMessagesCompanion.insert(
            sessionId: sessionId,
            role: 'assistant',
            content: response,
          ),
        );

    ref.invalidateSelf();
  }

  Future<String?> _resolveReferences(String text, AppDatabase db) async {
    final regex = RegExp(r'@chat:(\d+)');
    final matches = regex.allMatches(text);
    if (matches.isEmpty) return null;

    final buffer = StringBuffer('=== Contexte Référencé ===\n');
    for (final match in matches) {
      final refId = int.parse(match.group(1)!);
      final session = await (db.chatSessions.select()
            ..where((t) => t.id.equals(refId)))
          .getSingleOrNull();
      if (session == null) continue;

      final messages = await (db.chatMessages.select()
            ..where((t) => t.sessionId.equals(refId))
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(5))
          .get();

      buffer.writeln('\n--- Chat #${session.id}: ${session.title} ---');
      for (final msg in messages.reversed) {
        buffer.writeln('[${msg.role}] ${msg.content}');
      }
    }
    return buffer.toString();
  }

  Future<List<Map<String, String>>> _getRecentHistory(
      int sessionId, AppDatabase db) async {
    final messages = await (db.chatMessages.select()
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(10))
        .get();
    return messages.reversed
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();
  }
}
