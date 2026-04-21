import 'dart:io';

class FileNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;
  final bool isHidden;
  final bool isLazyLoad;

  const FileNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.children = const [],
    required this.isHidden,
    this.isLazyLoad = false,
  });

  static FileNode fromEntity(
    FileSystemEntity entity, {
    List<FileNode> children = const [],
    bool isLazyLoad = false,
  }) {
    final name = entity.path.split(Platform.pathSeparator).last;
    return FileNode(
      name: name,
      path: entity.path,
      isDirectory: entity is Directory,
      children: children,
      isHidden: name.startsWith('.'),
      isLazyLoad: isLazyLoad,
    );
  }
}
