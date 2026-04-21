import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database.g.dart';

@DataClassName('ChatSession')
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ChatMessage')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ChatSessions, #id)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ContextSnapshot')
class ContextSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ChatSessions, #id)();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [ChatSessions, ChatMessages, ContextSnapshots, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'neo_code_db'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await customStatement('''
          CREATE VIRTUAL TABLE chat_messages_fts USING fts5(
            content,
            content='chat_messages',
            content_rowid='id'
          );
        ''');
        await customStatement('''
          CREATE TRIGGER chat_messages_ai AFTER INSERT ON chat_messages BEGIN
            INSERT INTO chat_messages_fts(rowid, content) VALUES (new.id, new.content);
          END;
        ''');
        await customStatement('''
          CREATE TRIGGER chat_messages_ad AFTER DELETE ON chat_messages BEGIN
            INSERT INTO chat_messages_fts(chat_messages_fts, rowid, content) VALUES ('delete', old.id, old.content);
          END;
        ''');
        await customStatement('''
          CREATE TRIGGER chat_messages_au AFTER UPDATE ON chat_messages BEGIN
            INSERT INTO chat_messages_fts(chat_messages_fts, rowid, content) VALUES ('delete', old.id, old.content);
            INSERT INTO chat_messages_fts(rowid, content) VALUES (new.id, new.content);
          END;
        ''');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.create(appSettings);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<String?> getSetting(String key) async {
    final row = await (appSettings.select()
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await appSettings.insertOne(
      AppSettingsCompanion.insert(key: key, value: value),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteSetting(String key) async {
    await (appSettings.delete()..where((t) => t.key.equals(key))).go();
  }
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
