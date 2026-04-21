import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database.g.dart';

/// Table des sessions de chat (Cross-Chat Context)
@DataClassName('ChatSession')
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Table des messages avec liaison vers la session
@DataClassName('ChatMessage')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ChatSessions, #id)();
  TextColumn get role => text()(); // Typiquement 'user' ou 'assistant'
  TextColumn get content => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

/// Table des snapshots/résumés du contexte IA
@DataClassName('ContextSnapshot')
class ContextSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ChatSessions, #id)();
  TextColumn get content => text()(); // On y stockera du texte ou du JSON
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [ChatSessions, ChatMessages, ContextSnapshots])
class AppDatabase extends _$AppDatabase {
  // L'utilisation de driftDatabase de drift_flutter gère automatiquement
  // le meilleur emplacement pour la DB en fonction de l'OS (Windows, etc.)
  AppDatabase() : super(driftDatabase(name: 'neo_code_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // Crée toutes les tables standards définies ci-dessus
        await m.createAll();

        // --- Configuration FULL TEXT SEARCH (FTS5) ---
        // Création de la table virtuelle FTS5 pour activer la recherche ultra-rapide
        // sur le contenu des messages
        await customStatement('''
          CREATE VIRTUAL TABLE chat_messages_fts USING fts5(
            content,
            content='chat_messages',
            content_rowid='id'
          );
        ''');

        // Trigger: Synchronisation lors de l'insertion
        await customStatement('''
          CREATE TRIGGER chat_messages_ai AFTER INSERT ON chat_messages BEGIN
            INSERT INTO chat_messages_fts(rowid, content) VALUES (new.id, new.content);
          END;
        ''');

        // Trigger: Synchronisation lors de la suppression
        await customStatement('''
          CREATE TRIGGER chat_messages_ad AFTER DELETE ON chat_messages BEGIN
            INSERT INTO chat_messages_fts(chat_messages_fts, rowid, content) VALUES ('delete', old.id, old.content);
          END;
        ''');

        // Trigger: Synchronisation lors de la mise à jour
        await customStatement('''
          CREATE TRIGGER chat_messages_au AFTER UPDATE ON chat_messages BEGIN
            INSERT INTO chat_messages_fts(chat_messages_fts, rowid, content) VALUES ('delete', old.id, old.content);
            INSERT INTO chat_messages_fts(rowid, content) VALUES (new.id, new.content);
          END;
        ''');
      },
      beforeOpen: (details) async {
        // Activation obligatoire des Foreign Keys dans SQLite
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

// --- Provider Riverpod v3 (syntaxe classique) ---
// Note : Tu peux aussi utiliser riverpod_generator avec une classe @riverpod
// si tu préfères la nouvelle syntaxe, mais ceci est plus simple pour initialiser la DB.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Permet de fermer la connexion proprement quand le provider est détruit
  ref.onDispose(db.close);
  return db;
});
