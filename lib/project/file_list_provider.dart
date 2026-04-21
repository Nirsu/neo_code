import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:neo_code/project/file_node.dart';

part 'file_list_provider.g.dart';

const _ignoredDirs = {'.git'};
const _lazyDirs = {
  'node_modules',
  'build',
  '.dart_tool',
  '.idea',
  'dist',
  'out',
  '.next',
  '.nuxt',
  'target',
  'vendor',
  '__pycache__',
  '.cache',
};

@riverpod
Future<List<FileNode>> fileList(Ref ref, String projectPath) async {
  final dir = Directory(projectPath);
  if (!await dir.exists()) return [];

  final nodes = <FileNode>[];
  final entities = await dir.list().toList();

  entities.sort((a, b) {
    final aDir = a is Directory;
    final bDir = b is Directory;
    if (aDir != bDir) return aDir ? -1 : 1;
    return a.path
        .split(Platform.pathSeparator)
        .last
        .toLowerCase()
        .compareTo(
          b.path.split(Platform.pathSeparator).last.toLowerCase(),
        );
  });

  for (final entity in entities) {
    final name = entity.path.split(Platform.pathSeparator).last;

    if (entity is Directory) {
      if (_ignoredDirs.contains(name)) continue;

      if (_lazyDirs.contains(name)) {
        nodes.add(FileNode.fromEntity(entity, isLazyLoad: true));
      } else {
        try {
          final children = await ref.watch(
            fileListProvider(entity.path).future,
          );
          nodes.add(FileNode.fromEntity(entity, children: children));
        } catch (_) {
          nodes.add(FileNode.fromEntity(entity));
        }
      }
    } else {
      nodes.add(FileNode.fromEntity(entity));
    }
  }

  return nodes;
}
