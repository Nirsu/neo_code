import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:neo_code/database/database.dart' as db;

part 'chat_session_provider.g.dart';

@riverpod
class ActiveChatSession extends _$ActiveChatSession {
  @override
  int? build() => null;

  void switchTo(int id) {
    state = id;
  }

  Future<void> createNew() async {
    final database = ref.read(db.databaseProvider);
    final now = DateTime.now();
    final title = 'Chat ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final result = await database.into(database.chatSessions).insertReturning(
          db.ChatSessionsCompanion.insert(title: title),
        );
    state = result.id;
  }

  Future<void> deleteSession(int id) async {
    final database = ref.read(db.databaseProvider);
    await (database.chatMessages.delete()
          ..where((t) => t.sessionId.equals(id)))
        .go();
    await (database.chatSessions.delete()..where((t) => t.id.equals(id))).go();
    if (state == id) {
      state = null;
    }
  }
}

final allChatSessionsProvider =
    FutureProvider<List<db.ChatSession>>((ref) async {
  final database = ref.watch(db.databaseProvider);
  return (database.chatSessions.select()
        ..orderBy([
          (t) => OrderingTerm.desc(t.createdAt),
        ]))
      .get();
});
