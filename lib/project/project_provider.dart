import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:file_picker/file_picker.dart';

import 'package:neo_code/database/database.dart';

part 'project_provider.g.dart';

@riverpod
class Project extends _$Project {
  @override
  Future<String?> build() async {
    final db = ref.watch(databaseProvider);
    return db.getSetting('last_project_path');
  }

  Future<void> openNewProject() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select project folder',
    );
    if (path == null) return;

    final db = ref.read(databaseProvider);
    await db.setSetting('last_project_path', path);
    state = AsyncData(path);
  }

  Future<void> closeProject() async {
    final db = ref.read(databaseProvider);
    await db.deleteSetting('last_project_path');
    state = const AsyncData(null);
  }
}
